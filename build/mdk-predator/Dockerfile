# MDK-Predator Build Environment
# Ubuntu 24.04 with all dependencies and build tools

FROM ubuntu:24.04

LABEL maintainer="MDK-Predator Build"
LABEL description="Build environment for MDK-Predator PortaPack Application"
LABEL version="1.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/opt/gcc-arm-none-eabi/bin:${PATH}"

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    python3 \
    python3-pip \
    wget \
    curl \
    pkg-config \
    ca-certificates \
    ninja-build \
    make \
    dfu-util \
    liblz4-tool \
    libusb-1.0-0-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install ARM GCC toolchain
RUN mkdir -p /opt && cd /opt && \
    wget -q https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    tar xjf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    rm gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 && \
    ln -s gcc-arm-none-eabi-10.3-2021.10 gcc-arm-none-eabi

# Create working directories
WORKDIR /workspace
VOLUME ["/workspace/mdk-predator", "/workspace/build"]

# Copy build script
COPY build.sh /usr/local/bin/build-mdk-predator.sh
RUN chmod +x /usr/local/bin/build-mdk-predator.sh

# Default command
CMD ["/bin/bash"]
