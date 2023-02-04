# BP Logger support

![](https://img.shields.io/badge/Made%20with-Flutter-blue)

> Want to see how BP Logger works? Want to modify or create your own customised version
>
> Head over to BP Logger's open source [repository](https://www.github.com/theRookieCoder/bp_logger)

## Installation

> BP Logger is hopefully coming to the Play store soon!

### Android

1. Go to the [releases page](https://github.com/theRookieCoder/bp_logger/releases/latest)
2. Under assets, download the APK file on the device you want to install the app on
3. If your browser prompts you that APKs are dangerous, press OK. Don't worry, my app is malware free and you can verify that because it is open source
4. Once the download is complete, package installer should prompt you to install the app. Click 'Install'

### iOS

1. Since the App Store sucks for developers, you have to sideload BP Logger using [Altstore](https://www.altstore.io) (Open this link for installation instructions)
2. Go to the [releases page](https://github.com/theRookieCoder/bp_logger/releases/latest)
3. Under assets, download the IPA file on your iPhone or iPad
4. After you install Altstore, open it and go to the Apps tab and press the plus button in the top left
5. Find and open the IPA file you downloaded
6. The app will install but will be inaccessible after 7 days if you uninstall Altstore or Altserver

## Usage

### Sign in

When you open the app for the first time, the app will ask for a Google account. This account's Google Drive will be used to store your BP values. The BP values will be located in a folder called `BP Logger` and a file called `log`. The values are stored in a Google Sheets file so you can edit them, or import previous values.

When opening the app for the first time

- The app prompts you to select a Google account
- Choose the account that you want the BP values to be stored in
- When asked, give permission for the app to use Google Drive, BP Logger can only edit and delete files created by itself
- The next time you login, the app should automatically do so without you having to interact

### Log values

You need to be connected to the internet to log your BP values!

1. Enter your systolic and diastolic values in the respective fields
2. If you would like to log values to other dates, press the edit button beside the date to change the date
3. You can change the date to anything from today to 2 weeks before
4. Once you are done entering the values, press the 'Add to logs' button in the bottom right
5. The app should show a tick once the values have been successfully logged
6. If the app shows a cross, then something went wrong. You can try again

### Access log file

Instead of going to Google Drive everytime, you can use the app to acces the log file

1. Open the drawer by either swiping from the left, or tapping the button in the top left
2. You can also use this drawer to check which account is currenty signed in
3. Click the second option, which says 'Access file'
4. If you have Google Sheets or Google Drive, the file should open up in there, otherwise the Google Sheets website opens up

### Switch accounts

You can use multiple accounts with BP Logger if you wish to log 2 seperate sets of BP values

To switch user:

1. Open the drawer by either swiping from the left, or tapping the button in the top left
2. Tap the first option, which says 'Log out'
3. The app should reload itself and prompt you to select a Google account again
4. If your account is not there, then you can add it

## Help

If you keep getting an error, contact `ileshkt@gmail.com` for assistance