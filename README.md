# BP Logger

## What is it

BP Logger is a Flutter app that allows you to keep track of your BP by logging it in a file in Google Drive.  
To use BP Logger, you must first sign in with Google. Then BP Logger will use your Google account to access your Google Drive (with your permission).  
After that, BP Logger can add the date, time, diastolic, and systolic values to a GSheets file called log.

## Installing

Currently, BP Logger is not available in any app stores and hence has to sideloaded.

Alternatively, you can add the [website](https://bp-logger-rookie-coder.web.app) to your homescreen but this takes forever to load and does not perform very well (not that that matters much anyway)

### Android

You can sideload the Android version of BP Logger fairly easily.

- Firstly, head to the releases page in the right sidebar

- It should open up to the latest version

- Under assets, find a file called `bp_logger_x.x.x.apk` _make sure the file ends in `apk`_

- Simply click on it to download it

- Some browsers might warn you that `apk`s may be dangerous. Don't worry my app is malware free. If you are skeptical, simply browse through my code, it is open source after all

- After proceeding, the file should be downloaded

- Click on it and the package installer should run, installing BP Logger

- You can then launch the app like any other app

  > Note
  >
  > Updating sideloaded apps is not possible. You simply have to reinstall them

### iOS

Sideloading on iOS is not easy, and neither is it easy for me to publish my app in the App Store.

There are 2 ways of sideloading. The easiest is using AltStore

> You will need a Windows and Mac to use the AltStore method

- Follow the instructions on AltStore's [website](https://altstore.io/faq/)
- Once, you have the AltStore app on your iPhone, go to the Apps page and click the add icon
- Choose the ipad file you downloaded from github releases
- It should install and as long as your iPhone is connected to your computer once a week, it should renew

You can also the variety of other method, such as [this](installonair.com) website, or building from source

### From source

> You will need a Mac for building on iOS

- Install Dart and Flutter
- Clone this repository
- Connect your device, make sure Flutter can pick it up, and run `flutter run --release`
