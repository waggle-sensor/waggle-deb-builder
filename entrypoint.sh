#!/bin/bash -eu

# set deb package variables
NAME="${NAME}"
DESCRIPTION="${DESCRIPTION}"
MAINTAINER="${MAINTAINER:-sagecontinuum.org}"
ARCH="${ARCH:-all}"
PRIORITY="${PRIORITY:-optional}"

print_help() {
  echo """
usage: build.sh [-f]
Create the versioned Debian package.
 -f : force the build to proceed (debugging only) without checking for tagged commit
"""
}

FORCE=
while getopts "f?" opt; do
  case $opt in
    f) # force build
      echo "** Force build: ignore tag depth check **"
      FORCE=1
      ;;
    ?|*)
      print_help
      exit 1
      ;;
  esac
done

cd /repo

# determine version
VERSION_SHORT=$(git describe --tags --dirty | sed s/^v//)
VERSION_LONG=$(git describe --tags --long --dirty | sed s/^v//)

TAG_DEPTH=$(echo ${VERSION_LONG} | cut -d '-' -f 2)
if [[ -z "${FORCE}" && "${TAG_DEPTH}_" != "0_" ]]; then
  echo "Error:"
  echo "  The current git commit has not been tagged. Please create a new tag first to ensure a proper unique version number."
  echo "  Use -f to ignore error (for debugging only)."
  exit 1
fi

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

emptydir() {
  [ ! -e "${1}" ] || [ -z "$(ls ${1})" ]
}

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
