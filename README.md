```
@@@@@@@  @@@@@@     @@@@@@@@ @@@@@@@@  @@@@@@
  @!!   @@!  @@@    @@!      @@!      !@@
  @!!   @!@  !@!    @!!!:!   @!!!:!    !@@!!
  !!:   !!:  !!!    !!:      !!:          !:!
   :     : :. :      :        :       ::.: :
```

# ToFfs

Is a batch script port of original **kext2ffs** bash script [here](https://github.com/tuxuser/kext2ffs).

- [x] Download latest [GenFfs](https://github.com/tianocore/edk2-BaseTools-win32/raw/master/GenFfs.exe) & [GenSec](https://github.com/tianocore/edk2-BaseTools-win32/raw/master/GenSec.exe), place into `Bin` dir.
- [x] The `LabelProject` var in script can be: `Ozmosis` / `OpenCore`:
- [x] Place `OpenCore.efi` + `DXE-Dependency.bin` in `OpenCore` dir.
- [x] Place `OpenCoreDefaults.plist` in `OpenCoreDefaults` dir.
- [x] Place `Ozmosis.efi` + `DXE-Dependency.bin` in `Ozmosis` dir.
- [x] Place `OzmosisDefaults.plist` in `OzmosisDefaults` dir.
- [x] Place `*.efi` Driver in `Driver` dir.
- [x] Place `*.efi` App in `App` dir.
- [x] Place `*.kext` in `Kext` dir.
- [x] All generated files will be in `Output` dir.

```
.
├── App
│   └── HermitShellX64.efi
├── Bin
│   ├── GenFfs.exe
│   └── GenSec.exe
├── Driver
│   └── HfsPlus.efi
├── Kext
│   └── FakeSMC.kext
│       └── Contents
│           ├── Info.plist
│           └── MacOS
│               └── FakeSMC
├── OpenCore
│   ├── DXE-Dependency.bin
│   └── OpenCore.efi
├── OpenCoreDefaults
│   └── OpenCoreDefaults.plist
├── Output
│   ├── App
│   │   ├── HermitShellX64.ffs
│   │   └── HermitShellX64Compressed.ffs
│   ├── Driver
│   │   ├── HfsPlus.ffs
│   │   └── HfsPlusCompressed.ffs
│   ├── Kext
│   │   ├── FakeSMCKext.ffs
│   │   └── FakeSMCKextCompressed.ffs
│   ├── OpenCore
│   │   ├── OpenCore.ffs
│   │   └── OpenCoreCompressed.ffs
│   ├── OpenCoreDefaults
│   │   ├── OpenCoreDefaults.ffs
│   │   └── OpenCoreDefaultsCompressed.ffs
│   ├── Ozmosis
│   │   ├── Ozmosis.ffs
│   │   └── OzmosisCompressed.ffs
│   └── OzmosisDefaults
│       ├── OzmosisDefaults.ffs
│       └── OzmosisDefaultsCompressed.ffs
├── Ozmosis
│   ├── DXE-Dependency.bin
│   └── Ozmosis.efi
├── OzmosisDefaults
│   └── OzmosisDefaults.plist
├── README.md
└── ToFfs.bat
```
