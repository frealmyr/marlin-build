FROM python:3-slim-buster

RUN apt update && apt install -y curl build-essential g++ git

# Create a non-root user and group
RUN useradd -s /bin/sh -d /home/platformio -m docker
USER docker:docker

# Install PlatformIO Core
RUN python3 -c "$(curl -fsSL https://raw.githubusercontent.com/platformio/platformio/master/scripts/get-platformio.py)"
ENV PATH=/home/platformio/.platformio/penv/bin:$PATH

# Clone MarlinFirmware repository, checkout latest release tag
WORKDIR /home/platformio
RUN git clone https://github.com/MarlinFirmware/Marlin.git \
  && cd Marlin/ \
  && git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

COPY build-marlin.sh .
CMD ["bash", "/home/platformio/build-marlin.sh"]
