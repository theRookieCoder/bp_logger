clean:
    rm -vrf build/Payload build/*.apk build/*.ipa
    flutter clean

release version:
    flutter pub get
    flutter build apk
    flutter build ios
    mkdir -p "build/Payload/BP Logger.app"
    cp -R build/ios/iphoneos/Runner.app "build/Payload/BP Logger.app"
    zip -r build/bp_logger_v{{version}}.ipa build/Payload
    mv build/app/outputs/apk/release/app-release.apk build/bp_logger_v{{version}}.apk
    gh release create v{{version}} "build/bp_logger_v{{version}}.ipa" "build/bp_logger_v{{version}}.apk" -t "BP Logger {{version}}" -n "Changelog:"
