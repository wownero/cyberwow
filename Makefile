
watch:
	find cyberwow/lib/ -name '*.dart' | \
	entr kill -USR1 `cat /tmp/flutter.pid`

run:
	cd cyberwow && \
	flutter run --pid-file /tmp/flutter.pid

# clang -target aarch64-linux-android21 cyberwow/native/hello.c -o cyberwow/native/output/hello
c:
	clang -target x86_64-linux-android21 cyberwow/native/hello.c -o cyberwow/native/output/hello

push:
	adb push cyberwow/native/output/hello /data/local/tmp

test-android:
	adb shell /data/local/tmp/hello

test-c: c push test-android

build:
	cd cyberwow && \
	flutter build apk --target-platform android-arm64
