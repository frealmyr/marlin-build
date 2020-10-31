# Build Marlin firmware using docker

This docker image contains `platformio-core` and a bash script, for conveniently compiling Marlin firmware with your own configuration.

## Compiling firmware

To use this image, you need to provide a folder containing your `*.h` configuration files. Any files with this extension will be copied to the build folder, replacing the default configuration files that exists.

>Configuration examples for most Marlin based 3d-printers can be [found here.](https://github.com/MarlinFirmware/Configurations/tree/import-2.0.x/config/examples)

You also need to set the `BOARD` environment variable, containing the `default_envs` value for your 3d-printer control board. This value can in most cases be found the vendor page/repo, or in firmware guides by the community.



### docker-compose

You need to create a `.env` file containing `BOARD`, `MARLIN_FIRMWARE` and `MARLIN_CONFIGURATION` next to the `docker-compose.yml` file, there is a example in the `examples/` folder.

Run `docker-compose run build` to compile the marlin firmware.

### docker run

For the volumes and environment variables, you can choose between creating a `.env` file, setting the variables in your shell or editing the docker run command directly.

```bash
docker run --rm -it \
  -e BOARD \
  -v $MARLIN_FIRMWARE:/home/platformio/build \
  -v $MARLIN_CONFIGURATION:/home/platformio/CustomConfiguration \
  frealmyr/docker-marlin-build:latest
```

### Github Action

You can create a github action that automatically builds and pushes the firmware file when you make a commit to the main branch in your own repository.

Add the configuration for your 3d-printer in a folder named `Firmware/Configuration`, and copy the `github-action.yml` file provided in `Examples/` to your repository. When you push to master, you can check the yellow dot next to your commit, or navigate to the Actions to view the terminal output for the github action.

A live example of this setup is available here https://github.com/frealmyr/3d-lab.

## Docker environment variables

| Variable | Description| Reqired |
| :--- | :- | :-: |
| BOARD | Platformio default_envs | yes |
| UPDATE_SKIP | Skip firmware update prompt | no |
| UPDATE_FORCE | Update to latest Marlin release | no |
| USE_BRANCH | Compile using a branch instead of latest tag | no |

## Docker volume mounts

| Location inside container | Description |
| :--- | :- |
| /home/platformio/build | Output folder for compiled firmware |
| /home/platformio/CustomConfiguration | Input folder for custom configuration |
