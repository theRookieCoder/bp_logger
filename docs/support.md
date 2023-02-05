# BP Logger Support Page

> Want to see how BP Logger works? Want to modify or create your own customised version?
>
> Head over to the open source [repository](https://www.github.com/theRookieCoder/bp_logger)

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

You can also use a variety of other methods, such as [Install on Air]([installonair.com](https://installonair.com)), or building from source using Xcode on a Mac as [in the appropriate readme section](https://github.com/theRookieCoder/bp_logger#building-from-source)

## Usage

When you open the app for the first time, you will be asked to sign in to a Google account. Give permission for the app to use Google Drive, BP Logger will only be able to edit and delete files created by itself. This account's Google Drive will be used to store your blood pressure values. These will be written to a `log` file in a folder called `BP Logger`. The values are stored in a Google Sheets file so you can edit them, import previous values, share them, etc.

### Log values

You need to be connected to the internet to log your BP values!

1. Enter your systolic and diastolic values in the respective fields
2. If you would like to log the values of other dates, press the edit button beside the date to change the it
3. You can change the date to anything from today to a week before
4. Once you are done entering the values, tap 'add entry' in the bottom right
5. The app should show a tick once the values have been successfully logged
6. If the app shows a cross, something went wrong

### Access log file

Instead of searching for the file in Google Drive, you can use the app to access the log file.

1. Open the drawer by either swiping from the left, or tapping the button in the top left
2. You can also use this drawer to check which account is currenty signed in
3. Tap the 'Access file' option
4. If you have the Google Sheets or Google Drive app, the file should open up there, otherwise the file will be opened in a website

### Switch accounts

You can use multiple accounts with BP Logger if you wish to log seperate sets of blood pressure values.

To switch users;

1. Open the drawer by either swiping from the left, or tapping the button in the top left
2. Tap the 'Log out' option
3. The app should reload itself and prompt you to log in to a Google account again
4. If your account is not there, then you can add it
