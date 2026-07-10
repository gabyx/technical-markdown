## Docker

We provide 2 images based on `pandoc/latex:2.18-alpine` in
[gabyxgabyx/technical-markdown](https://hub.docker.com/r/gabyxgabyx/technical-markdown):

1. [**`gabyxgabyx/technical-markdown:latest-minimal`**](https://hub.docker.com/r/gabyxgabyx/technical-markdown/tags)
   : Minimal docker images including pandoc and all necessary tools to fully
   build your markdown. It does not include the folder `tools` and `convert` and
   your mounted Git repository needs to contain these as in this repository or
   by setting the environment variables described below. This is useful if you
   want to tweak the layout and styling of the document.
2. [**`gabyxgabyx/technical-markdown:latest`**](https://hub.docker.com/r/gabyxgabyx/technical-markdown/tags)
   : The full-fledged image which is used in this VS Code `.devcontainer` setup.
   It contains its baked `tools` and `tools/convert` folders which are used to
   compile your markdown.

The `<version>` above corresponds to either `latest` or the Git version tag
minus the `v` prefix.

### Environment Variables

Numbers refer to the container images above:

| Env. Name                | Default Value                                       | Description                                                                                     |
| ------------------------ | --------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `TECHMD_TOOLS_DIR`       | 1. not set                                          | The tools directory containing all files needed for the conversion.                             |
|                          | 2 . `/home/techmd/technical-markdown/tools`         |                                                                                                 |
| `TECHMD_CONVERT_DIR`     | 1. not set                                          | The convert directory containing the files needed for the `pandoc` converstion.                 |
|                          | 2 . `/home/techmd/technical-markdown/tools/convert` |                                                                                                 |
| `TECHMD_USE_SYSTEM_NODE` | 1. `true`                                           | Use the node installation on the system instead of installing a local one into the build folder |
|                          | 2. `true`                                           |                                                                                                 |

### Using the Docker Image

Either copy the `.devontainer` to your project (you don't need the `tools`
folder) and open the project in the VS Code remote container extension.

Alternatively you can always use:

```shell
docker run -v "<path-to-your-repo>:/workspace" \
    gabyxgabyx/technical-markdown:latest"
    ./gradlew build-html
```

### Extending the Technical-Markdown Docker Images

If you need special other tools and an other setup which might be useful for the
general images above, consider submitting an issue. Otherwise you can always
extend the existing images for [layout/styling](#editing-styles) changes with
another Dockerfile like:

```dockerfile
FROM gabyxgabyx/technical-markdown:latest-minimal as mycustomtechmd
// More Dockerfile commands ...
```

### Building the Technical-Markdown Docker Images

To build the images in this repository for customization use:

```shell
tools/docker/build.sh \
    --base-name "mycustomimage" \
    [--push-base-name "docker.io/superuser"] \
    [--push]
```
