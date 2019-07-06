#!/usr/bin/env bash

set -e

version="aba46a"
container="wownero-android-${version}"

echo "Building: ${container}"
echo

cd ../vendor/wownero
git fetch --all

git checkout $version
git submodule init && git submodule update

docker build -f utils/build_scripts/android64.Dockerfile -t $container .
docker create -it --name $container $container bash
docker cp ${container}:/src/build/release/bin .

