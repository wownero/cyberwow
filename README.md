# CyberWOW

A dumb android full node for Wownero.

## How to build

### Compile wownerod for android-arm64

```
pushd .
git clone https://github.com/wownero/wownero
cd wownero
git submodule init && git submodule update

docker build -f utils/build_scripts/android64.Dockerfile -t wownero-android .
# Create container
docker create -it --name wownero-android wownero-android bash
# Get binaries
docker cp wownero-android:/src/build/release/bin .
```

The binary needed is in `./bin/wownerod`.

### Install flutter and make sure it's in path

### Compile CyberWOW

```
popd
git clone https://github.com/fuwa0529/cyberwow/
cd cyberwow

# Copy wownerod that we just built
cp $PATH_TO_WOWNEROD cyberwow/cyberwow/native/output/a4m64/
# Generate a dummy x86_64 bin
touch cyberwow/cyberwow/native/output/x86_64/wownerod

make build
```

Resulting apk is in `cyberwow/cyberwow/build/app/outputs/apk/release/app-release.apk`.
