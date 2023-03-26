# BP Logger

BP Logger is an app that allows you to keep track of your blood pressure by logging it in a file in Google Drive.  
To use BP Logger, you must first sign in with Google.
Then, it will use your Google account to access your Google Drive (with your permission).  
After which it will add the date and time, and your systolic and diastolic values to a Google Sheets file when you input them.

## Installing

Currently, BP Logger is not available on any app stores, and has to be sideloaded.
Because of this, you cannot automatically update the app, you will have to manually check if there is a new version available.

Alternatively, you can add the [website](https://bp-logger-rookie-coder.web.app) to your homescreen, but it will be laggier than the app.

### Android

1. Go to the [latest release](https://github.com/theRookieCoder/bp_logger/releases/latest)
2. Download the file called `bp_logger_version.apk`, _make sure the file ends in `apk`_
3. Some browsers might warn you that `apk`s may be dangerous, you safely can ignore this warning.
   If you're skeptical, feel free to read through the [source code](https://github.com/theRookieCoder/bp_logger).
4. Open the downloaded file to install it

### iOS

The easiest way to sideload on iOS is using the [AltStore](https://altstore.io).
You will need a PC or Mac to use AltStore.

1. Follow the instructions on [AltStore's website](https://altstore.io), make sure you have the AltStore app on your iPhone
2. Go to the [latest release](https://github.com/theRookieCoder/bp_logger/releases/latest)
3. Download the file called `bp_logger_version.ipa`, _make sure the file ends in `ipa`_
4. Go to the Apps page in the AltStore app and click the add icon in the top left
5. Choose the ipa file you just downloaded, it should start installing
6. As long as your iPhone is connects to your computer (even wirelessly) at least once a week, it should continue to work

You can also use a variety of other methods to install `ipa` files, such as [Install on Air](https://installonair.com).  
You can also build from source and install to your iPhone using Xcode on a Mac as seen below.
However this will only last for a week before needing a rebuild.

## Building from Source

> You will need a Mac for building the iOS app

- [Install Flutter](https://docs.flutter.dev/get-started/install)
- Clone this repository using `git clone https://github.com/theRookieCoder/bp_logger.git` or `gh repo clone theRookieCoder/bp_logger`
- Connect your device, make sure Flutter can pick it up
- Run `flutter run --release` to install a release build
