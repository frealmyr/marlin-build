## Build Marlin firmware using docker

This is a simple repository for using docker to build Marlin firmware for 3d-printers.

The `./build-marlin.sh` script does the following

1. Builds the docker image, or skips build if you already created one on the current date.
2. Prompts if you wish to fetch the latest MarlinFirmware, with option to disable prompt.
3. Copy custom configuration files into the `MarlinFirmware/Marlin` folder.
4. Uses a docker container to build firmware, using `platformio core` on a non-root user.

### Custom Configuration

The included configuration is for `Ender 3 Pro` running on a `SKR Mini E3 V1.2`.

Other Marlin configuration examples can be [found here.](https://github.com/MarlinFirmware/Configurations/tree/import-2.0.x/config/examples)

### MarlinFirmware submodule update

The script asks if you wish to update to the latest MarlinFirmware release, you can create a local variable called `UPDATE_SKIP` to skip this prompt.

```bash
UPDATE_SKIP=yes
```
