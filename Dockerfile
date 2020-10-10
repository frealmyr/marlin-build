FROM python:3-slim-buster

# Install dependencies
RUN apt update && apt install -y curl build-essential g++

# Create a non-root user and group
RUN useradd -s /bin/sh -d /home/platformio -m docker

# Set the default user to run commands, everything RUN after this line will be as normal user!
USER docker:docker

# Install PlatformIO Core
RUN python3 -c "$(curl -fsSL https://raw.githubusercontent.com/platformio/platformio/develop/scripts/get-platformio.py)"

# Add platformio binaries to PATH
ENV PATH=/home/platformio/.platformio/penv/bin:$PATH
