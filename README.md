# kext2ffs

Is a batch script port of original **kext2ffs** script [here](https://github.com/tuxuser/kext2ffs) to working under Windows.

- Download latest [GenFfs](https://github.com/tianocore/edk2-BaseTools-win32/raw/master/GenFfs.exe) & [GenSec](https://github.com/tianocore/edk2-BaseTools-win32/raw/master/GenSec.exe), place into `bin` dir.
- Place `Ozmosis.efi` to generate in `ozm` dir
- Place `OzmosisDefaults.plist` to generate in `ozmdefault` dir
- Place `.efi`to generate in `efi` dir
- Place `.kext` to generate in `kexts` dir

All generated files will be in `ffs` dir

```
KextToFfs.bat
├───bin
├───efi
├───ffs
│   ├───efi
│   │   └───compress
│   ├───kexts
│   │   └───compress
│   ├───ozm
│   │   └───compress
│   └───ozmdefault
│       └───compress
├───kexts
├───ozm
└───ozmdefault
```