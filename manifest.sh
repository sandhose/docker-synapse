#!/bin/sh

set -au

source=$1
target=$2

docker () {
  echo docker $*
  /usr/local/bin/docker $*
}

archs="
  amd64:amd64:
  arm64v8:arm64:v8
  arm32v6:arm:v6
  i386:386:
"

images=""

for arch in $archs; do
  IFS=: read suffix arch variant <<EOF
$arch
EOF
  images="$images $source-$suffix"
done

docker manifest create --amend $target $images
for arch in $archs; do
  IFS=: read suffix arch variant <<EOF
$arch
EOF
  args="--os linux --arch $arch"
  if ! [ -z "$variant" ]; then
    args="$args --variant $variant"
  fi
  docker manifest annotate $args $target $source-$suffix
done

docker manifest push $target
