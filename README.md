# BP Logger

![](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)

BP Logger is an app that allows you to keep track of your blood pressure by logging it in a file in Google Drive.  
To use BP Logger, you must first sign in with Google. Then BP Logger will use your Google account to access your Google Drive (with your permission).  
After that, BP Logger can add the date, time, systolic, and diastolic values to a Google Sheets file.

## Installing

Currently, BP Logger is not available in any app stores and hence has to be sideloaded.

You cannot automatically update the app, you will have to manually check if there is a new version available.

Alternatively, you can add the [website](https://bp-logger-rookie-coder.web.app) to your homescreen but it will be laggier than the app.

### Android

You can sideload BP Logger on Android fairly easily.

1. Head to the [latest release](https://github.com/theRookieCoder/bp_logger/releases/latest)
2. Download the file called `bp_logger_version.apk`. _Make sure the file ends in `apk`_
3. Some browsers might warn you that `apk`s may be dangerous. You can ignore this warning, if you're skeptical, feel free to read through the source code
4. open the downloaded file to install it

### iOS

The easiest way to sideload an iOS is using [AltStore](https://altstore.io)

> You will need a Windows PC and Mac to use AltStore

1. Follow the instructions on [AltStore's website](https://altstore.io), you have the AltStore app on your iPhone
2. Head to the [latest release](https://github.com/theRookieCoder/bp_logger/releases/latest)
3. Download the file called `bp_logger_version.ipa`. _Make sure the file ends in `ipa`_
4. Go to the Apps page in the AltStore app and click the add icon
5. Choose the ipa file you just downloaded, it should install
6. As long as your iPhone is connects to your computer at least once a week, it should continue to work

You can also use a variety of other methods, such as [Install on Air]([installonair.com](https://installonair.com)), or building from source using Xcode on a Mac as seen below

## Building from Source

> You will need a Mac for building on iOS

- [Install Flutter](https://docs.flutter.dev/get-started/install)
- Clone this repository using `git clone https://github.com/theRookieCoder/bp_logger.git` or `gh repo clone theRookieCoder/bp_logger`
- Connect your device, make sure Flutter can pick it up, and run `flutter run --release`
