# Build Marlin firmware using docker

This docker image contains `platformio-core` and a bash script, for conveniently compiling Marlin firmware with your own configuration.

## Compiling firmware

To use this image, you need to provide a folder containing your `*.h` configuration files. All files with this extension will be copied to the `Marlin/` folder, replacing existing configuration files.

>Configuration examples for most Marlin based 3d-printers can be [found here.](https://github.com/MarlinFirmware/Configurations/tree/import-2.0.x/config/examples)

You also need to set the `BOARD` environment variable, this should contain the `default_envs` value for your 3d-printer control board. This value can in most cases be found the vendor page/repo, or in firmware guides by the community.

### docker-compose

You can create a `.env` file with the variables `BOARD`, `MARLIN_FIRMWARE` and `MARLIN_CONFIGURATION` next to the `docker-compose.yml` file, or set the variables in your shell.

There is an example `.env` file in the `examples/` folder.

Run `docker-compose run build` to compile the marlin firmware.

### docker run

You can source a `.env` file (_such as the one provided in the `examples/` folder_), set the shell variables manually or alter the environment and path arguments with values.

```bash
docker run --rm -it \
  -e BOARD \
  -v $MARLIN_FIRMWARE:/home/platformio/build \
  -v $MARLIN_CONFIGURATION:/home/platformio/CustomConfiguration \
  frealmyr/marlin-build:latest
```

### Github Action

You can create a github action that automatically builds and pushes the firmware file when you make a commit containing changes in your `CustomConfiguration` files.

Simply copy the `github-action.yml` file provided in `Examples/` to `.github/workflows/` in your personal repository.

You can alter the folders to your liking. I recommend adding your `*.h` configuration files to a folder named `Firmware/Configuration`, and use `Firmware/builds` for the compiled firmware output. If you make changes to the folder structure, remember to alter the monitored path in the github action yaml.

When you push a commit with configuration changes to master, you can check the yellow dot next to your commit, or navigate to the Actions to view the terminal output for the github action.

A live example of this setup is available here: https://github.com/frealmyr/3d-lab

## Docker environment variables

| Variable | Description| Required | Default | Example |
| :--- | :- | :-: | :-: | :--: |
| BOARD | Platformio default_envs | yes | `""` | `STM32F103RET6_creality` |
| USE_REPO | Compile using a different git repository | no | `""` | `https://github.com/frealmyr/Marlin` |
| USE_LATEST | Update to latest Marlin release tag | no | `""` | `true` |
| USE_TAG | Compile using a specific release tag | no | `""` | `2.0.7.1` |
| USE_BRANCH | Compile using a branch instead of latest tag | no | `""` | `bugfix-2.0.x` |
| FW_EXTENSION | Override firmware file extension type | no | `bin` | `hex` |

>Different branches and tag versions might use a different CONFIGURATION_H_VERSION, firmware build will fail in such a case. Requiring you to update your configuration files with upstream changes.

## Docker volume mounts

| Location inside container | Description |
| :--- | :- |
| /home/platformio/build | Output folder for compiled firmware |
| /home/platformio/CustomConfiguration | Input folder for custom configuration |
