## Build Marlin firmware using docker

This is a solution for using docker to build Marlin firmware for 3d-printers. Edit the configuration files in `CustomConfiguration` and run `./build-marlin.sh` to compile the firmware.

The `./build-marlin.sh` script does the following

1. Builds the docker image, or skips build if you already created one on the current date.
2. Prompts if you wish to fetch the latest MarlinFirmware release, with option to disable prompt using a `UPDATE_SKIP=yes` local variable set in your shell.
3. Changes the `default_envs` variable in `platformio.ini` to the value defined in the `board` file inside CustomConfiguration.
4. Then it copies all `.h` files from the CustomConfiguration folder, into the `MarlinFirmware/Marlin` folder, replacing the destination files.
5. Uses a docker container to build firmware, using `platformio core` on a non-root user.
6. Output the compiled firmware location.

### Custom Configuration

The included configuration is the default configuration for a `Ender 3` with a `SKR Mini E3 V2.0` aftermarket motherboard, [found here.](https://github.com/MarlinFirmware/Configurations/tree/import-2.0.x/config/examples/Creality/Ender-3/BigTreeTech%20SKR%20Mini%20E3%202.0)

You can fork this repository and adapt the configuration to suit your needs. The gitignore entry for `CustomConfiguration/` will ignore any changes you make withing this folder, allowing you to update the fork or contribute upstream without modifying your custom configuration.

>Other Marlin configuration examples can be [found here.](https://github.com/MarlinFirmware/Configurations/tree/import-2.0.x/config/examples)


### Advanced Configuration

In some cases you might want to change the variables not covered by `.h` configuration files alone, and you have the need to make changes inside the `MarlinFirmware/Marlin/src` folder.

The script currently have no logic for replacing files inside sub-folders, so i recommend you to update the `MarlinFirmware` submodule once, and then set the `UPDATE_SKIP=yes` local variable, so that you can edit the files inside `MarlinFirmware/Marlin/src` folder without the changes being discarded due to git hard reset.
