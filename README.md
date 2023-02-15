# avr-gcc 10.3 with C++ build scripts

**Disclaimer:** Scripts are provided as-is, if you encounter problems please raise an issue - while this toolchain is not our product, it is possible that someone will assist you. We (KP Labs) are using toolchin built with these scripts with success.

## Build steps
1. Clone this repository
2. Download necessary sources (see table below)
3. Apply `gcc.patch` to GCC source directory: `cd src/gcc-10.3.0 && patch -p0 < ../../gcc.patch`
4. Execute build commands in following order (with current directory being root of this repository)
    1. `make info` - Verify paths are correct
    2. `make binutils-linux` - Builds binutils for Linux (e.g. `avr-objcopy`)
    3. `make gcc-stage1-linux` - Minimal `avr-gcc` for Linux
    4. `make avr-libc` - Compiles `avr-libc` using `avr-gcc` built in previous step
    5. `make gcc-linux` - Builds final `avr-gcc` compiler
    6. `make gdb-linux` - Builds `avr-gdb` for Linux
    7. `make toolchain-linux` - Combines all previously built artifacts into single folder

    **At this point you should have working avr-gcc compiler with full C++ support**

    Following steps are required to build toolchain for Windows x64 (requires MinG64W toolchain):

    8. `make binutils-win64` - Builds binutils for Windows
    9. `make gdb-win64` - Builds `avr-gdb` for Windows
    10. `make toolchain-win64` - Combines all previously built artifacts into single folder along with required MinGW DLLs. Additionaly `.tar.gz` archive is created

| Component | Version | Folder               |
|-----------|---------|----------------------|
| Binutils  | 2.36    | `src/binutils-2.36`  |
| GCC       | 10.3.0  | `src/gcc-10.3.0`     |
| avr-libc  | 2.0.0   | `src/avr-libc-2.0.0` |
| GDB       | 10.2    | `src/gdb-10.2`       |

## Build dependencies
Unfortunately I'm not able to easily provide list of required dependencies. `build-essentials` (or equivalent) is good start. If something is missing, each step will report what is missing.

## Customizing
Each build step is described in separate Makefile in `makes` folder. You can tweak them to your needs. You probably would like to change number of make jobs. Artifacts from build steps are isolated so it is easy to rebuild e.g. only `avr-libc` from scratch by removing associated build & install folders without removing already build `gcc-stage1`.

Updating to newer versions of components would probably require update of `gcc.patch`. Please raise an issue in case of problems or successes.