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

# Get Arduino IDE structure
RUN wget https://downloads.arduino.cc/arduino-1.8.19-linux64.tar.xz && \
    tar -xf arduino-1.8.19-linux64.tar.xz && \
    rm arduino-1.8.19-linux64.tar.xz

# Get Teensy cores from GitHub
RUN mkdir -p arduino-1.8.19/hardware/teensy/avr && \
    cd arduino-1.8.19/hardware/teensy/avr && \
    wget https://github.com/PaulStoffregen/cores/archive/refs/heads/master.zip && \
    unzip master.zip && \
    mv cores-master/* . && \
    rm -rf cores-master master.zip

# Create empty libraries directory (CLion expects it to exist)
RUN mkdir -p arduino-1.8.19/hardware/teensy/avr/libraries

# Verify the structure
RUN echo "=== Teensy4 headers ===" && \
    ls -la /opt/teensy/arduino-1.8.19/hardware/teensy/avr/teensy4/*.h | head -10

# Set environment variables
ENV TEENSY_ROOT=/opt/teensy/arduino-1.8.19/hardware/teensy/avr
ENV ARDUINO_ROOT=/opt/teensy/arduino-1.8.19

WORKDIR /workspace
CMD ["/bin/bash"]