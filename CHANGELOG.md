# Changelog

## [1.2.1]

- All changes are now listed in CHANGELOG.md rather than in commit messages
- Removed DEVELOPING.md
- Added repository value in `pubspec.yaml`
- Removed flutter test dependency
- Changed Dart version from `>=2.12.3` to `>=2.12.0 <3.0.0`
- Removed local `animated_check.dart` and added the package as it is now null safe
- Updated `FileAppendDialog.dart`'s imports

## [1.2.0]

- Upgraded from Dart version 2.11.0 to 2.12.3 for sound null safety
- The package `animated_check` is now null safe and has been removed
- `animated_check` is local and null safe

The following files were not null safe and they now are:

- DriveHelper.dart
- FileAppendDialog.dart
- HomePage.dart
- LogOutDialog.dart

## [1.1.9]

- Removed the print statements in `DriveHelper.signInAndInit`
- Adjusted the way the version from `package_info_plus` is recieved
- Email address in `DrawerHeader` is now also in a `FittedBox`

## [1.1.8+1]

- There is now a fade animation for the `FutureBuilder`

## [1.1.8]

- There is now a DEVELOPING.md file
- Edited .gitignore
- Made more one liner functions use `=>`
- The `DriveHelper` contructor is now empty and DriveHelper has to be initialized using `signInAndInit`
- `signInAndInit` now also signs in the Google account
- GoogleUserAccount, GoogleSignIn, etc are now 100% isolated
- Removed `FailedPage`
- `HomePage` is enclosed in a `FutureBuilder` with the future `DriveHelper.signInAndInit`
- There is a loading indicator when `signInAndInit` is completing
- If `signInAndInit` fails, a page with error in Roboto Mono is shown

## [1.1.7]

- Added Google Fonts package for a monospaced error page
- Commented out `flutter_launcher_icons`, uncomment if needed
- Improved README.md
- Specified Java path for Gradle to JDK 15
- `DriveHelper`'s `init` now called `signInAndInit`, has to be called seperately and is asynchronous
- The `HomePage` now only loads if `DriveHelper.signInAndInit` is done
- Increased the speed of the tick animation in `FileAppendDialog`

## [1.1.6]

- Fixed broken Android signing
- Removed `LinearProgressIndicator` and `SnackBar`s
- Replaced with a dialog with future builder and an animated tick
- Previously, users dissmissing the Google sign in dialog caused the app to crash, this error is now handled

## [1.1.5]

- Added a proper support page using Github Pages
- Access file button in drawer directly opens file
- FileAcessDialog has been removed
- Updated several one line functions to use `=>`

## [1.1.4]

- Switched from `package_info` to `package_info_plus`
- Only wait for Flutter to initialize if platform is not web
- Better import comments
- Updated README.md
- The `LinearProgressIndicator` is hidden by replacing it with a `Container` rather than using `Opacity`
- `IconButton` is offset with a `Container` rather than a identical button

## [1.1.3]

- Added a material design heart icon as app icon
- App version in `AboutDialog` is now derived using `package_info`
