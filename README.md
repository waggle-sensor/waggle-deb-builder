# Waggle Debian Package Builder

Creates a Debian package builder docker image to be used by other repositories when building Debian packages for installation to Waggle nodes.

## Usage

To use this Debian package builder copy/paste the below code into a `./build.sh` file in your repository and replace the placeholder text.

```bash
#!/bin/bash -e

docker run --rm \
  -e NAME="deb-name-placeholder" \
  -e DESCRIPTION="Debian package description placeholder" \
  -v "$PWD:/repo" \
  waggle/waggle-deb-builder:latest
```

### Specify Dependencies

If your Debian package has installation depends (i.e. `DEPENDS`) use the below format

```bash
#!/bin/bash -e

docker run --rm \
  -e NAME="deb-name-placeholder" \
  -e DESCRIPTION="Debian package description placeholder" \
  -e "DEPENDS=dependency-deb-name-placeholder (>= 1.2.3)" \
  -v "$PWD:/repo" \
  waggle/waggle-deb-builder:latest
```
