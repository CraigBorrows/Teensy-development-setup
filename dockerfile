FROM debian:bookworm-slim

# Install ARM toolchain and build tools only
RUN apt-get update && apt-get install -y \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    cmake \
    make \
    git \
    wget \
    curl \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/teensy

# Get your consolidated Teensy cores and libraries
RUN git clone https://github.com/CraigBorrows/teensy_core_libs.git . && \
    rm -rf .git


# Set environment variables
ENV TEENSY_ROOT=/opt/teensy


WORKDIR /workspace
CMD ["/bin/bash"]