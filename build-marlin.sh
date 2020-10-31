#!/bin/bash

# Ask if wish to update MarlinFirmware to the latest release
if [[ -z $UPDATE_SKIP ]]; then
  if [[ -z $UPDATE_FORCE ]]; then
    echo ""
    echo "You are currently using MarlinFirmware release:" $(cd Marlin/ && git tag --points-at HEAD)
    read -r -p "Do you want to update MarlinFirmware to latest release? [y/N] " response
  else
    response=y
  fi
      case "$response" in
          [yY][eE][sS]|[yY])
              cd Marlin/
              git fetch origin
              git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
              echo "" && cd ..
              ;;
          *)
              echo ""
              ;;
      esac
fi

# Check if custom configuration files exists within the docker container
CONFIG_CHECK=$(ls -1 /home/platformio/CustomConfiguration/*.h 2>/dev/null | wc -l)
if [ $CONFIG_CHECK = 0 ]
then
  printf "\n\e[1;31mNo custom configuration files detected! \e[0maborting..\n"
  exit 1
fi

# Copy custom configuration files to Marlin folder
while IFS= read -r line; do
  cp /home/platformio/CustomConfiguration/${line}.h /home/platformio/Marlin/Marlin/${line}.h
done <<< $(find /home/platformio/CustomConfiguration/ -name '*.h' -exec basename {} .h \;)

# Change the default board with value in environment variable
sed -i "s/default_envs = .*/default_envs = $BOARD/g" /home/platformio/Marlin/platformio.ini

# Build Marlin firmware
printf "\n\e[1;35mCompiling marling firmware..\e[0m\n\n"
platformio run -d Marlin/

success=$?

if [[ ${success} -eq 0 ]]; then
  build_dir=/home/platformio/Marlin/.pio/build/$BOARD/
  output_dir=/home/platformio/build/$BOARD/

  printf "\n\n\e[1;32mCopying compiled firmware to output folder..\e[0m\n"
  mkdir -p $output_dir
  find $build_dir -name '*.bin' -exec cp -prv '{}' $output_dir ';'
else
  printf "\n\e[1;31mBuild failed! \e[0mCheck the output above for errors\n"
  exit 1
fi
