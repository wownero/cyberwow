# CyberWOW

A dumb android full node for Wownero.

<a href='https://play.google.com/store/apps/details?id=org.wownero.cyberwow'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png' height='80'/></a>

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

The binary needed is `./bin/wownerod`.

### Install flutter and make sure it's in path

### Compile CyberWOW

```
popd
git clone https://github.com/fuwa0529/cyberwow/
cd cyberwow

mkdir -p cyberwow/native/output/arm64
mkdir -p cyberwow/native/output/x86_64

# Copy wownerod that we just built
cp $PATH_TO_WOWNEROD cyberwow/native/output/arm64/
# Generate a dummy x86_64 bin
touch cyberwow/native/output/x86_64/wownerod

make build
```

Resulting apk is in `cyberwow/build/app/outputs/apk/release/app-release.apk`.
