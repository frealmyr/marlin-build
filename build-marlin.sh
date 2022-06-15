#!/bin/bash

# Override git repository
if [ "$USE_REPO" ]; then
  printf "\n\e[01;36mOverride Detected\e[0m\n"
  printf "Switching git repository to:\e[01;33m $USE_REPO\e[0m\n\n"
  rm -rf Marlin/
  git clone $USE_REPO
fi

# Override MarlinFirmware version using branch or tag
if [[ -v $USE_LATEST ]] && [[ -z $USE_TAG ]] && [[ -z $USE_BRANCH ]]; then
  printf "\n\e[01;36mOverride Detected\e[0m\n"
  cd Marlin/
  git fetch origin
  git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
  printf "\nYou are now using git tag:\e[01;33m $(git tag --points-at HEAD)\e[0m\n\n"
  cd ..
elif [[ $USE_TAG ]]; then
  printf "\n\e[01;36mOverride Detected\e[0m\n"
  cd Marlin/
  git fetch origin
  git checkout $USE_TAG
  printf "\nYou are now using git tag:\e[01;33m $(git tag --points-at HEAD)\e[0m\n\n"
  cd ..
elif [[ $USE_BRANCH ]]; then
  printf "\n\e[01;36mOverride Detected\e[0m\n"
  cd Marlin/
  git fetch origin
  git checkout $USE_BRANCH
  printf "\nYou are now using the latest commit in branch:\e[01;33m $(git branch | sed -n '/\* /s///p')\e[0m\n\n"
  cd ..
else
  cd Marlin/
  printf "\nYou are using git tag from docker image:\e[01;33m $(git tag --points-at HEAD)\e[0m\n\n"
  cd ..
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
printf "\e[1;35mCompiling Marlin firmware..\e[0m\n\n"
platformio run -d Marlin/

success=$?

# Override firmware file extension
if [ "$FW_EXTENSION" ]; then
  printf "\n\e[01;36mOverride Detected\e[0m\n"
  printf "Setting firmware file extension to:\e[01;33m $FW_EXTENSION\e[0m\n"
else
  FW_EXTENSION=bin
fi

if [[ ${success} -eq 0 ]]; then
  OUTPUT_DIR=/home/platformio/build/$BOARD
  mkdir -p $OUTPUT_DIR

  printf "\nCopying compiled firmware to output folder..\n"
  cd /home/platformio/Marlin/.pio/build/$BOARD

  if [ $(find . -name "*.${FW_EXTENSION}") ];
  then
    FIRMWARE_NAME=$(find . -name "*.${FW_EXTENSION}" -type f -exec basename {} .${FW_EXTENSION} ';')
    md5sum $FIRMWARE_NAME.$FW_EXTENSION > $OUTPUT_DIR/$FIRMWARE_NAME.md5
    cp $FIRMWARE_NAME.$FW_EXTENSION $OUTPUT_DIR

    printf "\nValidating firmware checksum.."
    if md5sum -c $OUTPUT_DIR/$FIRMWARE_NAME.md5;
    then
      printf "\e[0mMD5 Checksum Validation: \e[1;32mSucceeded\n"
      echo ""
      echo "  (\.   \      ,/)"
      echo "   \(   |\     )/    Yer done!"
      echo "   //\  | \   /\\"
      echo "  (/ /\_#oo#_/\ \)   Happy 3D-Printing!"
      echo "   \/\  ####  /\/"
      echo "        '##'"
      echo ""
    else
      printf "\e[0mMD5 Checksum Validation: \e[1;31mFailed\n"
      printf "\n\e[1;31mBuild failed! \e[0mCheck the output above for errors\n"
      exit 1
    fi
  else
      printf "\e[0mMD5 Checksum Validation: \e[1;31mFirmware file with $FW_EXTENSION file extension not found!\n"
      printf "\n\e[1;31mBuild failed! \e[0mCheck the output above for errors\n"
      exit 1
  fi
else
  printf "\n\e[1;31mBuild failed! \e[0mCheck the output above for errors\n"
  exit 1
fi
