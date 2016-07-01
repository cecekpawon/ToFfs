@echo off

rem KextToFfs script by FredWst and STLVNUB
rem Win port @cecekpawon | thrsh.net | 6/23/2016 3:09:41 PM

set "workDir=%CD%"
set "dBIN=%workDir%\bin"
set "dOZMDefault=%workDir%\ozmdefault"
set "dOZM=%workDir%\ozm"
set "dFFS=%workDir%\ffs"
set "dDriver=%workDir%\driver"
set "dApp=%workDir%\app"
set "dKEXT=%workDir%\kexts"
set "dTMP=%workDir%\tmp"

set kId=10

set fn=

echo "*********************************"
echo "* Convert Kext to FFS type file *"
echo "*********************************"
echo.

rem :prepareDir
  for /R "%workDir%" %%i in (._*) do del /S "%%i"
  rd /S /Q "%dFFS%">nul
  call:createDir "%dFFS%\ozm\compress"
  call:createDir "%dFFS%\ozmdefault\compress"
  call:createDir "%dFFS%\driver\compress"
  call:createDir "%dFFS%\app\compress"
  call:createDir "%dFFS%\kexts\compress"
  call:createDir "%dTMP%"
  fsutil file createnew "%dTMP%\NullTerminator" 1
  echo WScript.Echo Hex(WScript.Arguments(0))>"%dTMP%\hex.vbs"

rem :generateOzmosis
  echo Generate Ozmosis:
  call:ozm2ffs

rem :generateOzmosisDefaults
  echo Generate OzmosisDefaults:
  call:ozmdefault2ffs

rem :generateEfiDriver
  echo Generate Efi Driver:
  for /R "%dDriver%" %%i in (*.efi) do call:driver2ffs "%%i"

rem :generateEfiApp
  echo Generate Efi App:
  for /R "%dApp%" %%i in (*.efi) do call:app2ffs "%%i"

rem :generateKext
  echo Generate Kexts:
  for /D %%i in ("%dKEXT%"\*) do call:kext2ffs "%%i"

goto done

:createDir
  if not exist "%~1" mkdir "%~1"
  goto:eof

:getFn
  set fn=%~n1
  goto:eof

:ozm2ffs
  if not exist "%dOZM%\DXE-Dependency.bin" goto:eof
  if not exist "%dOZM%\Ozmosis.efi" goto:eof

  %dBIN%\GenSec -s EFI_SECTION_DXE_DEPEX -o "%dTMP%\Ozmosis-0.pe32" "%dOZM%\DXE-Dependency.bin"
  %dBIN%\GenSec -s EFI_SECTION_PE32 -o "%dTMP%\Ozmosis.pe32" "%dOZM%\Ozmosis.efi"
  %dBIN%\GenSec -s EFI_SECTION_USER_INTERFACE -n "Ozmosis" -o "%dTMP%\Ozmosis-1.pe32"
  %dBIN%\GenFfs -t EFI_FV_FILETYPE_DRIVER -g AAE65279-0761-41D1-BA13-4A3C1383603F -o "%dFFS%\ozm\Ozmosis.ffs" -i "%dTMP%\Ozmosis-0.pe32" -i "%dTMP%\Ozmosis.pe32" -i "%dTMP%\Ozmosis-1.pe32"

  %dBIN%\GenSec -s EFI_SECTION_COMPRESSION -o "%dTMP%\Ozmosis-2.pe32" "%dTMP%\Ozmosis.pe32" "%dTMP%\Ozmosis-1.pe32"
  %dBIN%\GenFfs -t EFI_FV_FILETYPE_DRIVER -g AAE65279-0761-41D1-BA13-4A3C1383603F -o "%dFFS%\ozm\compress\OzmosisCompress.ffs" -i "%dTMP%\Ozmosis-0.pe32" -i "%dTMP%\Ozmosis-2.pe32"

  echo - "%dOZM%\Ozmosis.efi" will be Ffs "0" name in boot.log will be Ozmosis
  goto:eof

:ozmdefault2ffs
  if not exist "%dOZMDefault%\OzmosisDefaults.plist" goto:eof

  rem %dBIN%\GenSec -s EFI_SECTION_PE32 -o "%dTMP%\OzmosisDefaults.pe32" "%dOZMDefault%\OzmosisDefaults.plist"
  %dBIN%\GenSec -s EFI_SECTION_RAW -o "%dTMP%\OzmosisDefaults.pe32" "%dOZMDefault%\OzmosisDefaults.plist"
  %dBIN%\GenSec -s EFI_SECTION_USER_INTERFACE -n "OzmosisDefaults" -o "%dTMP%\OzmosisDefaults-1.pe32"

  %dBIN%\GenFfs -t EFI_FV_FILETYPE_FREEFORM -g 99F2839C-57C3-411E-ABC3-ADE5267D960D -o "%dFFS%\ozmdefault\OzmosisDefaults.ffs" -i "%dTMP%\OzmosisDefaults.pe32" -i "%dTMP%\OzmosisDefaults-1.pe32"
  %dBIN%\GenSec -s EFI_SECTION_COMPRESSION -o "%dTMP%\OzmosisDefaults-2.pe32" "%dTMP%\OzmosisDefaults.pe32" "%dTMP%\OzmosisDefaults-1.pe32"
  %dBIN%\GenFfs -t EFI_FV_FILETYPE_FREEFORM -g 99F2839C-57C3-411E-ABC3-ADE5267D960D -o "%dFFS%\ozmdefault\compress\OzmosisDefaultsCompress.ffs" -i "%dTMP%\OzmosisDefaults-2.pe32"

  echo - "%dOZMDefault%\OzmosisDefaults.plist" will be Ffs "0" name in boot.log will be "OzmosisDefaults"
  goto:eof

:driver2ffs
  call:getFn "%~1"
  set b=%fn%
  set c=%b%Compress

  set guid=0

  if ["%b%"] == ["EnhancedFat"] (
    set guid=961578FE-B6B7-44C3-AF35-6BC705CD2B1F
  ) else (
    if ["%b%"] == ["HfsPlus"] (
      set guid=4CF484CD-135F-4FDC-BAFB-1AA104B48D36
    ) else (
      if ["%b%"] == ["Extfs"] (
        set guid=B34E5765-2E04-4DAF-867F-7F40BE6FC33D
      )
    )
  )

  if "%guid%" NEQ "0" (
    %dBIN%\GenSec -s EFI_SECTION_PE32 -o "%dTMP%\%b%.pe32" "%~1"
    %dBIN%\GenSec -s EFI_SECTION_USER_INTERFACE -n "%b%" -o "%dTMP%\%b%-1.pe32"
    %dBIN%\GenFfs -t EFI_FV_FILETYPE_DRIVER -g %guid% -o "%dFFS%\driver\%b%.ffs" -i "%dTMP%\%b%.pe32" -i "%dTMP%\%b%-1.pe32"

    %dBIN%\GenSec -s EFI_SECTION_COMPRESSION -o "%dTMP%\%b%-2.pe32" "%dTMP%\%b%.pe32" "%dTMP%\%b%-1.pe32"
    %dBIN%\GenFfs -t EFI_FV_FILETYPE_DRIVER -g %guid% -o "%dFFS%\driver\compress\%c%.ffs" -i "%dTMP%\%b%-2.pe32"

    echo - "%~1" will be Ffs "0" name in boot.log will be "%b%"
  )
  goto:eof

:app2ffs
  call:getFn "%~1"
  set b=%fn%
  set c=%b%Compress

  set guid=0

  if ["%b%"] == ["HermitShellX64"] (
    set guid=C57AD6B7-0515-40A8-9D21-551652854E37
  )

  if "%guid%" NEQ "0" (
    %dBIN%\GenSec -s EFI_SECTION_PE32 -o "%dTMP%\%b%.pe32" "%~1"
    %dBIN%\GenSec -s EFI_SECTION_USER_INTERFACE -n "%b%" -o "%dTMP%\%b%-1.pe32"
    %dBIN%\GenSec -s EFI_SECTION_GUID_DEFINED "%dTMP%\%b%.pe32" "%dTMP%\%b%-1.pe32" -o "%dTMP%\%b%-2.pe32"
    %dBIN%\GenFfs -t EFI_FV_FILETYPE_APPLICATION -s -g %guid% -o "%dFFS%\app\%b%.ffs" -i "%dTMP%\%b%-2.pe32"

    %dBIN%\GenSec -s EFI_SECTION_COMPRESSION -o "%dTMP%\%b%-3.pe32" "%dTMP%\%b%-2.pe32"
    %dBIN%\GenFfs -t EFI_FV_FILETYPE_APPLICATION -s -g %guid% -o "%dFFS%\app\compress\%c%.ffs" -i "%dTMP%\%b%-3.pe32"

    echo - "%~1" will be Ffs "0" name in boot.log will be "%b%"
  )
  goto:eof

:kext2ffs
  call:getFn "%~1"
  set b=%fn%
  set b2=%b%Kext
  set c=%b%KextCompress

  if "%kId%" GEQ "16" (
    echo Cannot convert "%~1", valid GUID limit exceed: id ^(%kId%^)
    goto:eof
  )

  set id=0

  if ["%b%"] == ["FakeSMC"] (
    set id=1
  ) else (
    if ["%b%"] == ["AppleEmulator"] (
      set id=1
    ) else (
      if ["%b%"] == ["SmcEmulator"] (
        set id=1
      ) else (
        if ["%b%"] == ["Disabler"] (
          set id=2
        ) else (
          if ["%b%"] == ["Injector"] (
            set id=3
          ) else (
            if ["%b%"] == ["CPUSensors"] (
              set id=6
            ) else (
              if ["%b%"] == ["LPCSensors"] (
                set id=7
              ) else (
                if ["%b%"] == ["GPUSensors"] (
                  set id=8
                ) else (
                  if ["%b%"] == ["VoodooHDA"] (
                    set id=9
                  ) else (
                    set id=%kId%
                    set /A kId=%kId%+1
                  )
                )
              )
            )
          )
        )
      )
    )
  )

  if "%id%" GEQ "10" (
    cscript //nologo "%dTMP%\hex.vbs" %id%>"%dTMP%\hex.txt"
  ) else (
    echo "%id%">"%dTMP%\hex.txt"
  )

  set /P gId=<"%dTMP%\hex.txt"

  copy /B /Y "%~1\Contents\Info.plist"+"%dTMP%\NullTerminator"+"%~1\Contents\MacOS\%b%" "%dTMP%\%b%.bin">nul

  rem %dBIN%\GenSec -s EFI_SECTION_PE32 -o "%dTMP%\%b%.pe32" "%dTMP%\%b%.bin"
  %dBIN%\GenSec -s EFI_SECTION_RAW -o "%dTMP%\%b%.pe32" "%dTMP%\%b%.bin"
  %dBIN%\GenSec -s EFI_SECTION_USER_INTERFACE -n "%b2%" -o "%dTMP%\%b%-1.pe32"

  %dBIN%\GenFfs -t EFI_FV_FILETYPE_FREEFORM -g DADE100%gId%-1B31-4FE4-8557-26FCEFC78275 -o "%dFFS%\kexts\%b2%.ffs" -i "%dTMP%\%b%.pe32" -i "%dTMP%\%b%-1.pe32"
  %dBIN%\GenSec -s EFI_SECTION_COMPRESSION -o "%dTMP%\%b%-2.pe32" "%dTMP%\%b%.pe32" "%dTMP%\%b%-1.pe32"
  %dBIN%\GenFfs -t EFI_FV_FILETYPE_FREEFORM -g DADE100%gId%-1B31-4FE4-8557-26FCEFC78275 -o "%dFFS%\kexts\compress\%c%.ffs" -i "%dTMP%\%b%-2.pe32"

  echo - "%~1" will be Ffs "%id%" name in boot.log will be "%b2%"
  goto:eof

:done
  rd /S /Q "%dTMP%">nul

pause
