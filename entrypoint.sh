#!/bin/bash -eu

get_version_short() {
  git describe --tags --dirty 2>/dev/null || echo "v0.0.0"
}

get_version_long() {
  git describe --tags --long --dirty 2>/dev/null || echo "v0.0.0-$(git rev-parse --short HEAD)"
}

trim_version_prefix() {
  sed -e 's/^v//'
}

emptydir() {
  [ ! -e "${1}" ] || [ -z "$(ls ${1})" ]
}

# set deb package variables
NAME="${NAME}"
DESCRIPTION="${DESCRIPTION}"
MAINTAINER="${MAINTAINER:-sagecontinuum.org}"
ARCH="${ARCH:-all}"
PRIORITY="${PRIORITY:-optional}"

cd /repo

# determine version
VERSION_SHORT=$(get_version_short | trim_version_prefix)
echo "VERSION_SHORT: ${VERSION_SHORT}"
VERSION_LONG=$(get_version_long | trim_version_prefix)
echo "VERSION_LONG: ${VERSION_LONG}"

# setup deb build directory
BASEDIR="$(mktemp -d)"
mkdir -p "$BASEDIR/DEBIAN"

# add package metadata
cat > "$BASEDIR/DEBIAN/control" <<EOF
Package: ${NAME}
Version: ${VERSION_LONG}
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
Architecture: ${ARCH}
Priority: ${PRIORITY}
EOF

# add package tools
if emptydir ROOTFS; then
  echo "ROOTFS/ is missing"
  exit 1
fi

echo "adding files in ROOTFS"
cp -pr ROOTFS/* "${BASEDIR}/"

if ! emptydir deb/install; then
  echo "adding files in deb/install"
  cp -p deb/install/* "${BASEDIR}/DEBIAN/"
fi

# build deb in output directory
mkdir -p output/
cd output/
dpkg-deb --root-owner-group --build "${BASEDIR}" "${NAME}_${VERSION_SHORT}_${ARCH}.deb"
