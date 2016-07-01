# kext2ffs

Is a batch script port of original **kext2ffs** script [here](https://github.com/tuxuser/kext2ffs) to working under Windows.

- Download latest [GenFfs](https://github.com/tianocore/edk2-BaseTools-win32/raw/master/GenFfs.exe) & [GenSec](https://github.com/tianocore/edk2-BaseTools-win32/raw/master/GenSec.exe), place into `bin` dir.
- Place `Ozmosis.efi` + `DXE-Dependency.bin` in `ozm` dir
- Place `OzmosisDefaults.plist` in `ozmdefault` dir
- Place `.efi` driver in `driver` dir
- Place `.efi` app in `app` dir
- Place `.kext` to generate in `kexts` dir

All generated files will be in `ffs` dir

```
│   KextToFfs.bat
│   README.md
│
├───app
│       HermitShellX64.efi
│
├───bin
│       GenFfs.exe
│       GenSec.exe
│
├───driver
│       HfsPlus.efi
│
├───ffs
│   ├───app
│   │   │   HermitShellX64.ffs
│   │   │
│   │   └───compress
│   │           HermitShellX64Compress.ffs
│   │
│   ├───driver
│   │   │   HfsPlus.ffs
│   │   │
│   │   └───compress
│   │           HfsPlusCompress.ffs
│   │
│   ├───kexts
│   │   │   SmcEmulatorKext.ffs
│   │   │
│   │   └───compress
│   │           SmcEmulatorKextCompress.ffs
│   │
│   ├───ozm
│   │   │   Ozmosis.ffs
│   │   │
│   │   └───compress
│   │           OzmosisCompress.ffs
│   │
│   └───ozmdefault
│       │   OzmosisDefaults.ffs
│       │
│       └───compress
│               OzmosisDefaultsCompress.ffs
│
├───kexts
│   └───SmcEmulator.kext
│       └───Contents
│           │   Info.plist
│           │
│           └───MacOS
│                   SmcEmulator
│
├───ozm
│       DXE-Dependency.bin
│       Ozmosis.efi
│
└───ozmdefault
        OzmosisDefaults.plist
```