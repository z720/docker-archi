# Docker Image to run Archi Script in a container

This image is intended to be used with [Archi](https://www.archimatetool.com) mainly for the use-case of generateing content from a model in CI/CD pipeline context.

Basically a wrapper for `Archi -application com.archimatetool.commandline.app -consoleLog -nosplash $ARGS`

## How to use

Run the following command to generate the HTML report:

```shell
docker run --rm -it -v="`pwd`":/data z720/archi archi -m /data --script /data/scripts/archi-report-script/generateReports.ajs --html /data/html --pluginDir /data/plugins
```

If you have a compiled version of the JArchi script plugin (see [Github project](https://github.com/archimatetool/archi-scripting-plugin) or get a binary version from the [Archi project Patreon page](https://www.patreon.com/architool/posts?filters[tag]=jArchi).)

You can run the script `report.ajs` by placing the `.archiplugin` file in the `plugins` directory with the following command:

```shell
docker run --rm -it -v="`pwd`":/data z720/archi archi -m /data --script /data/report.ajs --pluginDir /data/plugins
```

## Available options

- `--model | -m <path>` Path to the model local repository or file
- `--pluginDir <path>` Directory containing the plugins necessary for the command. Any `.archiplugin` file will be installed in the **Archi** instance before running the command. 
- `--html <path>`: Activate the generation of the HTML report in the provided *path*
- `--script <filename>` Path to the script to execute. Requires to provide the script plugin.
- `--help | -h` Display command line help

All the paths should be in a folder exposed via the docker *volume* bindings.

## How to contribute

If you'd like to contribute, start by searching through the issues and pull requests to see whether someone else has raised a similar idea or question.

If you don't see your idea listed, and you think it fits into the goals of this guide, open a pull request.