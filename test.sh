#!/bin/bash -eu

pass() {
  echo "--> PASS"
}

fail() {
  echo "--> FAIL"
  exit $1
}

DOCKERTAG="waggle-deb-builder:test"
docker build . -t ${DOCKERTAG}

echo "01: Test required Debian package parameter [NAME]..."
if ! docker run --rm \
        ${DOCKERTAG} ; then
    pass
else
    fail 1
fi

echo "02: Test required Debian package parameter [DESCRIPTION]..."
if ! docker run --rm \
        -e NAME="test02-name" \
        ${DOCKERTAG} ; then
    pass
else
    fail 2
fi

echo "03: Test required Debian package content [/repo]..."
if ! docker run --rm \
        -e NAME="test03-name" \
        -e DESCRIPTION="test description" \
        ${DOCKERTAG} ; then
    pass
else
    fail 3
fi

echo "04: Test required Debian package content [/repo/ROOTFS/]..."
if ! docker run --rm \
        -e NAME="test04-name" \
        -e DESCRIPTION="test description" \
        -v "$PWD:/repo" \
        ${DOCKERTAG}  ; then
    pass
else
    fail 4
fi

echo "05: Test successful Debian package creation..."
if docker run --rm \
        -e NAME="test05-name" \
        -e DESCRIPTION="test description" \
        -v "$PWD/testdebs/valid:/repo" \
        ${DOCKERTAG}  ; then
    pass
else
    fail 5
fi

echo "06: Test successful Debian package creation w/ depends..."
if docker run --rm \
        -e NAME="test06-name" \
        -e DESCRIPTION="test description" \
        -e DEPENDS="deb (>= 1.0.0), deb2" \
        -v "$PWD/testdebs/valid:/repo" \
        ${DOCKERTAG}  ; then
    pass
else
    fail 6
fi

echo "07: Test successful Debian package creation w/ deb/install..."
if docker run --rm \
        -e NAME="test07-name" \
        -e DESCRIPTION="test description" \
        -v "$PWD/testdebs/valid_debinstall:/repo" \
        ${DOCKERTAG}  ; then
    pass
else
    fail 7
fi
