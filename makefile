.PHONY: all build clean

test:
	flutter run --release

clean:
	flutter clean
	rm -vrf Payload
	rm *.apk
	rm *.ipa

build:
	flutter pub get
	flutter build apk
	flutter build ios
	cd build
	mkdir -p Payload
	cp -R ~/flutter_projects/bp_logger/build/ios/iphoneos/Runner.app "Payload/BP Logger.app"
	zip "bp_logger_v${VERSION}.ipa" Payload
	mv ~/flutter_projects/bp_logger/build/app/outputs/flutter-apk/app-release.apk bp_logger_v${VERSION}.apk
	gh release create v${VERSION} "bp_logger_v${VERSION}.ipa" "bp_logger_v${VERSION}.apk" -t "BP Logger ${VERSION}" -n "Native builds for sideloading"
