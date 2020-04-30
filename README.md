# CyberWOW

A dumb android pruned full node for Wownero.

[<img src="https://f-droid.org/badge/get-it-on.png"
      alt="Get it on F-Droid"
      height="80">](https://f-droid.org/en/packages/org.wownero.cyberwow/)
<a href='https://play.google.com/store/apps/details?id=org.wownero.cyberwow'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png' height='80'/></a>


## How to build

An example build script that works on an F-droid build server, which is based on debian stable, is here:

<https://gitlab.com/fdroid/fdroiddata/-/raw/master/metadata/org.wownero.cyberwow.yml>

## How to use custom start up arguments

Sending the arguments to an unopened CyberWOW app will cause `wownerod` to use them on start up, for example:

`--add-exclusive-node 192.168.1.3`

## F-droid build status

<https://f-droid.org/wiki/page/org.wownero.cyberwow/lastbuild>
