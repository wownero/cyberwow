# CyberWOW

A dumb android pruned full node for Wownero.

[<img src="https://f-droid.org/badge/get-it-on.png"
      alt="Get it on F-Droid"
      height="80">](https://f-droid.org/en/packages/org.wownero.cyberwow/)
<a href='https://play.google.com/store/apps/details?id=org.wownero.cyberwow'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png' height='80'/></a>

## How to build

### Compile wownerod for android-arm64

#### Simple method with Docker

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

#### Alternative methods

1. One docker instance per hash

See `etc/scripts/build-wownero.sh`, modify the value of `version` per build.

2. Debian based system similar to F-droid

See the `wow` task in `Makefile`.

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

The resulting apk is `cyberwow/build/app/outputs/apk/release/app-release.apk`.
