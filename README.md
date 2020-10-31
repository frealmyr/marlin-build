## Build Marlin firmware using docker

This docker image contains `platformio-core` and a bash script for convenient compiling of Marlin firmware with custom configuration.

You need to provide your own folder with `*.h` configuration files, configuration examples can be [found here.](https://github.com/MarlinFirmware/Configurations/tree/import-2.0.x/config/examples)

The `frealmyr/docker-marlin-build:lastest` image is built automatically every month using Github Actions.

### Compiling firmware

>Either of these choices requires you to define a `CustomConfiguration` folder that contains your `*.h` configuration files, and a correct `BOARD` environment variable to match your configuration.

#### docker-compose

Create either a `.env` file containing the `MARLIN_FIRMWARE` and `MARLIN_CONFIGURATION` folder locations, or use environment variables in your shell.

Run `docker-compose run build` to compile the marlin firmware.

#### docker run

Run the following command, changing the directory references

```bash
docker run --rm -it \
  -e BOARD \
  -v $MARLIN_FIRMWARE:/home/platformio/build \
  -v $MARLIN_CONFIGURATION:/home/platformio/CustomConfiguration \
  frealmyr/docker-marlin-build:latest
```

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
