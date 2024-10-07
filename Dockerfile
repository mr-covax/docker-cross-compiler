# State 1: configuring Ubuntu and dependencies
FROM ubuntu:noble AS base

ARG target="x86_64-elf" 
ARG gccVer="14.2.0"
ARG binutilsVer="2.43"
ARG prefix="/opt/toolchain"

ENV PATH="${prefix}/bin:${PATH}"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    build-essential \
    bison \
    curl \
    ca-certificates \
    flex \
    git \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    libisl-dev \
    nano \
    texinfo \
    vim \
    zstd

RUN rm -rf /var/lib/apt/lists/*


# Stage 2: building cross-compiled binutils
FROM base AS binutils-build

WORKDIR ${prefix}

RUN curl \
    -f "https://ftp.gnu.org/gnu/binutils/binutils-${binutilsVer}.tar.zst" \
    -o /var/tmp/binutils.tar.zst

RUN mkdir -p ./build/binutils-${binutilsVer}/artifacts
RUN tar -xf /var/tmp/binutils.tar.zst -C ./build

RUN cd build/binutils-${binutilsVer}/artifacts \
    && ../configure --target=${target} --prefix="${prefix}" --with-sysroot --disable-nls --disable-werror \
    && make -j $(nproc) \
    && make install \
    && rm -rf ${prefix}/build


# Stage 3: build the cross-compiler
FROM binutils-build AS gcc-build

WORKDIR ${prefix}

RUN curl \
    -f "https://ftp.gnu.org/gnu/gcc/gcc-${gccVer}/gcc-${gccVer}.tar.xz" \
    -o /var/tmp/gcc.tar.xz

RUN mkdir -p ./build/gcc-${gccVer}/artifacts
RUN tar -xf /var/tmp/gcc.tar.xz -C ./build

RUN cd ./build/gcc-${gccVer}/artifacts \
    && ../configure --target=${target} --prefix=${prefix} --disable-nls --enable-languages=c,c++ --without-headers \
    && make -j $(nproc) all-gcc \
    && make -j $(nproc) all-target-libgcc \
    && make install-gcc \
    && make install-target-libgcc \
    && rm -rf ${prefix}/build


# Stage 4: combine the previous stages into one 
FROM base AS final

COPY --from=binutils-build /opt/toolchain /opt/toolchain
COPY --from=gcc-build /opt/toolchain /opt/toolchain