## Build Marlin firmware using docker

This is a simple repository for using docker to build Marlin firmware for 3d-printers.

The `./build-marlin.sh` script does the following

1. Builds the docker image, skips build if you already created one on the current date.
2. Prompts if you wish to fetch the latest MarlinFirmware.
3. Copies the custom configuration files into the MarlinFirmware/Marlin folder.
4. Uses docker container to build firmware using platformio core on a non-root user.

### Custom Configuration

The included configuration is for `Ender 3 Pro` running on a `SKR Mini E3 V1.2`.

Other Marlin configuration examples can be [found here.](https://github.com/MarlinFirmware/Configurations)

### Marlin Firmware submodule update

The script asks if you wish to update to the latest Marlin release, you can create a local variable name `UPDATE_SKIP` to skip this prompt if you are going to run the script multiple times.

```bash
UPDATE_SKIP=yes
```
