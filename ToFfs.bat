@echo off

:: -
:: KextToFfs script by FredWst and STLVNUB | https://github.com/tuxuser/kext2ffs
:: Win port @cecekpawon | https://github.com/cecekpawon/ToFfs | 6/23/2016 3:09:41 PM
:: -

:: -
:: Ozmosis / OpenCore
set LabelProject=Ozmosis
:: -

set LabelProjectDefaults=%LabelProject%Defaults
set LabelOutput=Output
set LabelDriver=Driver
set LabelApp=App
set LabelKext=Kext
set LabelTmp=Tmp
set LabelBin=Bin
set LabelBinUrl=https://github.com/tianocore/edk2-BaseTools-win32
set LabelCompressed=Compressed

set "DirWork=%CD%"

set "DirProject=%DirWork%\%LabelProject%"
set "DirProjectDefaults=%DirWork%\%LabelProjectDefaults%"
set "DirOutput=%DirWork%\%LabelOutput%"
set "DirDriver=%DirWork%\%LabelDriver%"
set "DirApp=%DirWork%\%LabelApp%"
set "DirKext=%DirWork%\%LabelKext%"
set "DirTmp=%DirWork%\%LabelTmp%"
set "DirBin=%DirWork%\%LabelBin%"

set "DirOutputProject=%DirOutput%\%LabelProject%"
set "DirOutputProjectDefaults=%DirOutput%\%LabelProjectDefaults%"
set "DirOutputDriver=%DirOutput%\%LabelDriver%"
set "DirOutputApp=%DirOutput%\%LabelApp%"
set "DirOutputKext=%DirOutput%\%LabelKext%"

set "UtilTmpFile=%DirTmp%\TmpFile"
set "UtilNullTerminator=%DirTmp%\NullTerminator"
set "UtilHex=%DirTmp%\Hex.vbs"
set "UtilCrLf=%DirTmp%\CrLf.vbs"

set KextId=0
set GeneratedFilename=

:: #
:: #
:: #

echo.
echo @@@@@@@  @@@@@@     @@@@@@@@ @@@@@@@@  @@@@@@
echo   @!!   @@!  @@@    @@!      @@!      !@@
echo   @!!   @!@  !@!    @!!!:!   @!!!:!    !@@!!
echo   !!:   !!:  !!!    !!:      !!:          !:!
echo    :     : :. :      :        :       ::.: :
echo.

:: #
:: #
:: #

cd "%DirWork%"

goto:BinPrepare

:: #
:: #
:: #

:BinDie

  echo.
  echo [ *** ERROR  *** ] Required binary in '%LabelBin%' directory doesnt exists
  echo [ *** ERROR  *** ] Download latest binary file (s) from '%LabelBinUrl%'

  goto:Done

:KextDie

  echo [ *** ERROR  *** ] Failed to create helper file (s) for generating Kext Ffs

  goto:Done

:: #
:: #
:: #

:BinPrepare

  echo.
  echo Checking requirements (GenSec / GenFfs)

  set BinGenSec=%DirBin%\GenSec.exe
  set BinGenFfs=%DirBin%\GenFfs.exe

  if not exist "%BinGenSec%" goto:BinDie
  if not exist "%BinGenFfs%" goto:BinDie

:: -
:: DirPrepare
:: -

  echo.
  echo Preparing directories
  echo.

  del /s "%DirWork%"\._* >nul 2>&1
  del /s /a:h "%DirWork%"\._* >nul 2>&1
  rd /s /q "%DirOutput%"
  call:CreateDir "%DirOutputProject%"
  call:CreateDir "%DirOutputProjectDefaults%"
  call:CreateDir "%DirOutputDriver%"
  call:CreateDir "%DirOutputApp%"
  call:CreateDir "%DirOutputKext%"
  call:CreateDir "%DirTmp%"
  fsutil file createnew "%UtilNullTerminator%" 1 >nul
  echo WScript.Echo Hex(WScript.Arguments(0))>"%UtilHex%"
  (  echo set FSO = CreateObject("Scripting.FileSystemObject"^)
     echo set Input = FSO.OpenTextFile(WScript.Arguments(0^), 1^)
     echo Buffer = Replace(Input.ReadAll, VbCrLf, VbLf^)
     echo set Output = FSO.CreateTextFile(WScript.Arguments(1^), True^)
     echo Output.Write Buffer
     echo Input.Close
     echo Output.Close)>"%UtilCrLf%"

:: -
:: GenerateProject
:: -

  echo.
  echo Generate %LabelProject%:
  echo.

  call:GenerateProject

:: -
:: GenerateProjectDefaults
:: -

  echo.
  echo Generate %LabelProjectDefaults%:
  echo.

  call:GenerateProjectDefaults

:: -
:: GenerateEfiDriver
:: -

  echo.
  echo Generate Efi Driver:
  echo.

  for /R "%DirDriver%" %%i in (*.efi) do call:GenerateEfiDriver "%%i"

:: -
:: GenerateEfiApp
:: -

  echo.
  echo Generate Efi App:
  echo.

  for /R "%DirApp%" %%i in (*.efi) do call:GenerateEfiApp "%%i"

:: -
:: GenerateKext
:: -

  echo.
  echo Generate Kext:
  echo.

  if not exist "%UtilNullTerminator%" goto:KextDie
  if not exist "%UtilHex%" goto:KextDie
  if not exist "%UtilCrLf%" goto:KextDie

  for /D %%i in ("%DirKext%"\*) do call:GenerateKext "%%i"

goto:Done

:: #
:: #
:: #

:CreateDir

  if not exist "%~1" mkdir "%~1"
  goto:eof

:GetFilename

  set GeneratedFilename=%~n1
  goto:eof

:: #
:: #
:: #

:GenerateProject

  set Filename=%LabelProject%
  set OutputCompressedFilename=%Filename%%LabelCompressed%
  set DependencyFilename=DXE-Dependency

  set GuidString=AAE65279-0761-41D1-BA13-4A3C1383603F

  if not exist "%DirProject%\%DependencyFilename%.bin" goto:eof
  if not exist "%DirProject%\%Filename%.efi" goto:eof

  %BinGenSec% -s EFI_SECTION_DXE_DEPEX -o "%DirTmp%\%Filename%-0.pe32" "%DirProject%\%DependencyFilename%.bin"
  %BinGenSec% -s EFI_SECTION_PE32 -o "%DirTmp%\%Filename%.pe32" "%DirProject%\%Filename%.efi"
  %BinGenSec% -s EFI_SECTION_USER_INTERFACE -n "%Filename%" -o "%DirTmp%\%Filename%-1.pe32"
  %BinGenFfs% -t EFI_FV_FILETYPE_DRIVER -g %GuidString% -o "%DirOutputProject%\%Filename%.ffs" -i "%DirTmp%\%Filename%-0.pe32" -i "%DirTmp%\%Filename%.pe32" -i "%DirTmp%\%Filename%-1.pe32"
  %BinGenSec% -s EFI_SECTION_COMPRESSION -o "%DirTmp%\%Filename%-2.pe32" "%DirTmp%\%Filename%.pe32" "%DirTmp%\%Filename%-1.pe32"
  %BinGenFfs% -t EFI_FV_FILETYPE_DRIVER -g %GuidString% -o "%DirOutputProject%\%OutputCompressedFilename%.ffs" -i "%DirTmp%\%Filename%-0.pe32" -i "%DirTmp%\%Filename%-2.pe32"

  echo - %Filename%: %Filename%.ffs ^(%OutputCompressedFilename%.ffs^) ^| %GuidString%

  goto:eof

:: #
:: #
:: #

:GenerateProjectDefaults

  set Filename=%LabelProjectDefaults%
  set OutputCompressedFilename=%Filename%%LabelCompressed%

  set GuidString=99F2839C-57C3-411E-ABC3-ADE5267D960D

  if not exist "%DirProjectDefaults%\%Filename%.plist" goto:eof

  %BinGenSec% -s EFI_SECTION_RAW -o "%DirTmp%\%Filename%.pe32" "%DirProjectDefaults%\%Filename%.plist"
  %BinGenSec% -s EFI_SECTION_USER_INTERFACE -n "%Filename%" -o "%DirTmp%\%Filename%-1.pe32"
  %BinGenFfs% -t EFI_FV_FILETYPE_FREEFORM -g %GuidString% -o "%DirOutputProjectDefaults%\%Filename%.ffs" -i "%DirTmp%\%Filename%.pe32" -i "%DirTmp%\%Filename%-1.pe32"
  %BinGenSec% -s EFI_SECTION_COMPRESSION -o "%DirTmp%\%Filename%-2.pe32" "%DirTmp%\%Filename%.pe32" "%DirTmp%\%Filename%-1.pe32"
  %BinGenFfs% -t EFI_FV_FILETYPE_FREEFORM -g %GuidString% -o "%DirOutputProjectDefaults%\%OutputCompressedFilename%.ffs" -i "%DirTmp%\%Filename%-2.pe32"

  echo - %Filename%: %Filename%.ffs ^(%OutputCompressedFilename%.ffs^) ^| %GuidString%

  goto:eof

:: #
:: #
:: #

:GenerateEfiDriver

  call:GetFilename "%~1"

  set Filename=%GeneratedFilename%
  set OutputCompressedFilename=%Filename%%LabelCompressed%

  set GuidString=

  if ["%Filename%"] == ["EnhancedFat"] (
    set GuidString=961578FE-B6B7-44C3-AF35-6BC705CD2B1F
  ) else (
    if ["%Filename%"] == ["HfsPlus"] (
      set GuidString=4CF484CD-135F-4FDC-BAFB-1AA104B48D36
    ) else (
      if ["%Filename%"] == ["Extfs"] (
        set GuidString=B34E5765-2E04-4DAF-867F-7F40BE6FC33D
      )
    )
  )

  if not ["%GuidString%"] == [""] (
    %BinGenSec% -s EFI_SECTION_PE32 -o "%DirTmp%\%Filename%.pe32" "%~1"
    %BinGenSec% -s EFI_SECTION_USER_INTERFACE -n "%Filename%" -o "%DirTmp%\%Filename%-1.pe32"
    %BinGenFfs% -t EFI_FV_FILETYPE_DRIVER -g %GuidString% -o "%DirOutputDriver%\%Filename%.ffs" -i "%DirTmp%\%Filename%.pe32" -i "%DirTmp%\%Filename%-1.pe32"
    %BinGenSec% -s EFI_SECTION_COMPRESSION -o "%DirTmp%\%Filename%-2.pe32" "%DirTmp%\%Filename%.pe32" "%DirTmp%\%Filename%-1.pe32"
    %BinGenFfs% -t EFI_FV_FILETYPE_DRIVER -g %GuidString% -o "%DirOutputDriver%\%OutputCompressedFilename%.ffs" -i "%DirTmp%\%Filename%-2.pe32"

    echo - %Filename%: %Filename%.ffs ^(%OutputCompressedFilename%.ffs^) ^| %GuidString%
  )

  goto:eof

:: #
:: #
:: #

:GenerateEfiApp

  call:GetFilename "%~1"

  set Filename=%GeneratedFilename%
  set OutputCompressedFilename=%Filename%%LabelCompressed%

  set GuidString=

  if ["%Filename%"] == ["HermitShellX64"] (
    set GuidString=C57AD6B7-0515-40A8-9D21-551652854E37
  )

  if not ["%GuidString%"] == [""] (
    %BinGenSec% -s EFI_SECTION_PE32 -o "%DirTmp%\%Filename%.pe32" "%~1"
    %BinGenSec% -s EFI_SECTION_USER_INTERFACE -n "%Filename%" -o "%DirTmp%\%Filename%-1.pe32"
    %BinGenSec% -s EFI_SECTION_GUID_DEFINED "%DirTmp%\%Filename%.pe32" "%DirTmp%\%Filename%-1.pe32" -o "%DirTmp%\%Filename%-2.pe32"
    %BinGenFfs% -t EFI_FV_FILETYPE_APPLICATION -s -g %GuidString% -o "%DirOutputApp%\%Filename%.ffs" -i "%DirTmp%\%Filename%-2.pe32"
    %BinGenSec% -s EFI_SECTION_COMPRESSION -o "%DirTmp%\%Filename%-3.pe32" "%DirTmp%\%Filename%-2.pe32"
    %BinGenFfs% -t EFI_FV_FILETYPE_APPLICATION -s -g %GuidString% -o "%DirOutputApp%\%OutputCompressedFilename%.ffs" -i "%DirTmp%\%Filename%-3.pe32"

    echo - %Filename%: %Filename%.ffs ^(%OutputCompressedFilename%.ffs^) ^| %GuidString%
  )

  goto:eof

:: #
:: #
:: #

:GenerateKext

  call:GetFilename "%~1"

  set Filename=%GeneratedFilename%
  set OutputFilename=%Filename%%LabelKext%
  set OutputCompressedFilename=%Filename%%LabelKext%%LabelCompressed%

  set "MacOSBin=%~1\Contents\MacOS\%Filename%"
  set "PlistOriginal=%~1\Contents\Info.plist"

  if not exist "%MacOSBin%" goto:eof
  if not exist "%PlistOriginal%" goto:eof

  if %KextId% GEQ 255 (
    echo Cannot convert "%~1", valid GUID limit exceed: id ^(%KextId%^)
    goto:eof
  )

  set GuidId=%KextId%

  if %KextId% GEQ 10 (
    cscript //nologo "%UtilHex%" %KextId%>"%UtilTmpFile%"
    set /P GuidId=<"%UtilTmpFile%"
  )

  if %KextId% LEQ 15 (
    set GuidId=0%GuidId%
  )

  set GuidString=DADE10%GuidId%-1B31-4FE4-8557-26FCEFC78275

  "%UtilCrLf%" "%PlistOriginal%" "%UtilTmpFile%"
  if not exist "%UtilTmpFile%" goto:eof
  copy /B /Y "%UtilTmpFile%"+"%UtilNullTerminator%"+"%MacOSBin%" "%DirTmp%\%Filename%.bin" >nul

  %BinGenSec% -s EFI_SECTION_RAW -o "%DirTmp%\%Filename%.pe32" "%DirTmp%\%Filename%.bin"
  %BinGenSec% -s EFI_SECTION_USER_INTERFACE -n "%OutputFilename%" -o "%DirTmp%\%Filename%-1.pe32"
  %BinGenFfs% -t EFI_FV_FILETYPE_FREEFORM -g %GuidString% -o "%DirOutputKext%\%OutputFilename%.ffs" -i "%DirTmp%\%Filename%.pe32" -i "%DirTmp%\%Filename%-1.pe32"
  %BinGenSec% -s EFI_SECTION_COMPRESSION -o "%DirTmp%\%Filename%-2.pe32" "%DirTmp%\%Filename%.pe32" "%DirTmp%\%Filename%-1.pe32"
  %BinGenFfs% -t EFI_FV_FILETYPE_FREEFORM -g %GuidString% -o "%DirOutputKext%\%OutputCompressedFilename%.ffs" -i "%DirTmp%\%Filename%-2.pe32"

  echo - %Filename%: %OutputFilename% ^(%OutputCompressedFilename%^) ^| %KextId% ^(0x%GuidId%^) ^| %GuidString%

  set /A KextId=%KextId%+1

  goto:eof

:: #
:: #
:: #

:Done

  rd /s /q "%DirTmp%" >nul

echo.
echo P   A   E
echo  \ / \ /
echo   E   C
echo.

pause
