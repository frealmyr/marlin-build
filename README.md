## Build Marlin firmware using docker

This docker image contains `platformio-core` and a bash script for convenient compiling of Marlin firmware with your own configuration.

The `frealmyr/docker-marlin-build:lastest` image is built automatically every month using Github Actions.

## Compiling firmware

This solution requires you to define a `CustomConfiguration` folder that contains your `*.h` configuration files, and a correct `BOARD` environment variable containing the `default_envs` for your 3d-printer control board.

>Configuration examples can be [found here.](https://github.com/MarlinFirmware/Configurations/tree/import-2.0.x/config/examples)

### docker-compose

Create either a `.env` file containing the `MARLIN_FIRMWARE` and `MARLIN_CONFIGURATION` folder locations, or use environment variables in your shell.

Run `docker-compose run build` to compile the marlin firmware.

### docker run

Run the following command, changing the directory references

```bash
docker run --rm -it \
  -e BOARD \
  -v $MARLIN_FIRMWARE:/home/platformio/build \
  -v $MARLIN_CONFIGURATION:/home/platformio/CustomConfiguration \
  frealmyr/docker-marlin-build:latest
```

### Github Action

You can create a github action that automatically builds and pushes the firmware file when you make a commit to the main branch in your own repository.

There is a example file in `Examples/` that you can copy to your own repository, and you can see a live example of this setup here https://github.com/frealmyr/3d-lab.

### Docker environment variables

| Variable | Description| Reqired |
| :---: | :-: | :-: |
| BOARD | Platformio default_envs | yes |
| UPDATE_SKIP | Skip firmware update prompt | no |
| UPADTE_FORCE | Update to latest marlin release | no |

### Docker volume mounts

| Variable | Description |
| :---: | :-: |
| /home/platformio/build | Output folder for built firmware |
| /home/platformio/CustomConfiguration | Input folder for custom configuration files |
