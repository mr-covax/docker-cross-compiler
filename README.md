This repository is an example of how to use Docker and Dockerfiles to configure the cross-compiling toolchain with GCC and binutils. As of now, it uses Ubuntu 24.04 as the base image and builds the toolchain from source.

# Build instructions
1. Clone this repository onto your system
2. Move to the cloned repository
3. For best experience, make sure that Docker Buildx is installed. Please, consult your distribution's documentation for installation instructions.
4. Execute: `docker build -t gcc-cross-toolchain .`
5. Use the built container, either by running a container base on it or using it as a Dev Container in Visual Studio Code.

# Customization
This Dockerfile also defines the following arguments:
- `gccVer` - the version of GCC to pull and compile
- `binutilsVer` - the version of Binutils to pull and compile
- `target` - the triplet describing the CPU architecture and operating system to build the toolchain for
- `prefix` - where to install the toolchain inside the final container

FYI, to change an argument during build-time, run
```bash
docker build --build-arg <argument>=<the new value> -t gcc-cross-toolchain .
```

# License
This project is distributed under the MIT license. Consult the LICENSE file for more information.
