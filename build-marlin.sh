#!/bin/bash

# set to true to ignore updating marlin to latest version
UPDATE_SKIP=

# Check if the docker image is older than a day, skip building if you already built the image today
today=$(date '+%Y-%m-%d')
image_date=$(docker inspect --format "{{json .Created}}" local/platformio | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}')

if [[ ${today} != ${image_date} ]]; then
  docker build . -t local/platformio
fi

# Ask if wish to update MarlinFirmware to the latest release
if [[ -z ${UPDATE_SKIP} ]]; then
  read -r -p "Do you want to update MarlinFirmware to latest release? [y/N] " response
  case "$response" in
      [yY][eE][sS]|[yY])
          git submodule foreach --recursive git clean -xfd
          git submodule foreach --recursive git reset --hard
          git submodule foreach 'git fetch origin; git checkout $(git describe --tags `git rev-list --tags --max-count=1`);'
          ;;
      *)
          ;;
  esac
fi

# Store .h configuration files in CustomConfiguration folder to a variable
CONFIG_FILES=$(find CustomConfiguration -name '*.h' -exec basename {} .h \;)

# Remove configuration files if they exist in Marlin folder
while IFS= read -r line; do
    rm -f $(pwd)/MarlinFirmware/${line}.h
done <<< "$CONFIG_FILES"

# Copy custom configuration files to Marlin folder, symlink will not work as they wont be mounted in docker image
while IFS= read -r line; do
  cp $(pwd)/CustomConfiguration/${line}.h $(pwd)/MarlinFirmware/Marlin/${line}.h
done <<< "$CONFIG_FILES"

# Change the default board with value in board file. sed is borked on MacOS so the rm/mv is a ugly workaround
sed "s/default_envs = .*/default_envs = $(cat $(pwd)/CustomConfiguration/board)/" $(pwd)/MarlinFirmware/platformio.ini > $(pwd)/MarlinFirmware/platformio.ini_new
rm $(pwd)/MarlinFirmware/platformio.ini
mv $(pwd)/MarlinFirmware/platformio.ini_new $(pwd)/MarlinFirmware/platformio.ini

# Build the Marlin firmware
docker run --rm -it \
  -v $(pwd)/MarlinFirmware:/home/platformio/MarlinFirmware \
  -w /home/platformio/MarlinFirmware \
  local/platformio platformio run

echo "If the output above reported SUCCESS, you can now find the firmware in the following folder"
echo "./MarlinFirmware/.pio/build/$(cat $(pwd)/CustomConfiguration/board)"
