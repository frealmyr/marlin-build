#!/bin/bash

function help()
{
	printf "Usage:\n$0\n"
	printf "\n"
	printf "OPTIONS:\n"
	printf "  -h  help     : Show this message\n"
	printf "  -s  skip     : Skip update of MarlinFirmware to latest release\n"
	printf "  -f  force    : Force update of MarlinFirmware to latest release\n"
  printf "  -d  docker   : Build docker image locally, instead of pulling image\n"
	printf "\n"
}

# set to true to ignore updating marlin to latest version
UPDATE_SKIP=
# set to true to force an update of marlin to latest version
UPDATE_FORCE=
# set to true to build a local docker image
DOCKER_BUILD=

options=':hsfd'
while getopts $options option
do
    case ${option} in
        s  ) UPDATE_SKIP=true;;
        f  ) UPDATE_FORCE=true;;
        d  ) DOCKER_BUILD=true;;
        h  ) help; exit;;
        \? ) printf "Unknown option: -$OPTARG\n\n"; exit 1;;
    esac
done

# Build the docker image locally if the flag is set, else use docker hub
if [[ -n "$DOCKER_BUILD" ]]; then
  echo "Building platformio docker image locally.."
  docker build . -t frealmyr/platformio:latest
fi

# Ask if wish to update MarlinFirmware to the latest release
if [[ -z ${UPDATE_SKIP} ]]; then
  if [[ -z ${UPDATE_FORCE} ]]; then
    read -r -p "Do you want to update MarlinFirmware to latest release? [y/N] " response
  else
    response=y
  fi
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
  frealmyr/platformio:latest platformio run

success=$?

if [[ ${success} -eq 0 ]]; then
    build_dir=./MarlinFirmware/.pio/build/$(cat $(pwd)/CustomConfiguration/board)/
    output_dir=$(pwd)/build/$(cat $(pwd)/CustomConfiguration/board)/$(date '+%Y-%m-%d')/

    echo "Copying compiled firmware to output folder.."
    mkdir -p $output_dir
    find $build_dir -name '*.bin' -exec cp -prv '{}' $output_dir ';'

    printf "\n\e[1;32mBuild succeeded! \n\n\e[1;36mThe compiled firmware is available from: \n\e[0m$output_dir\n"
else
    printf "\n\e[1;31mBuild failed! \e[0mCheck the output above for errors\n"
    exit 1
fi
