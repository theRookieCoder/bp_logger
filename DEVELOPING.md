# This document roughly outlines how BP Logger works internally

## Signing in and initialization

1. The entry point of any Flutter application is the `main` function
2. Here, I simply called runApp and provided the MyApp stateless widget
3. In the `build` function, one has to return the widget that they want to display
4. I return a future builder with three states:

- Future resolved without errors
  - Display the `HomePage` and pass `driveHelper` to it
- Future resolved with errors
  - Display a `Scaffold` with a `Column` of 2 `Text`s. In the second `Text`, I display the error returned, with a monospaced font
- Future not resolved
  - I display a `Scaffold` with a `CircularProgressIndicator` enclosed in a `SizedBox` of size 200<sup>2</sup>
- The future provided is `DriveHelper.signInAndInit`. It does the following:
  - Creates a `GoogleSignIn` with the `DriveApi.driveFileScope`
  - Updates `account` with the an awaited `GoogleSignInAccount` from `signInWithGoogle`
    - Errors from `catchError` are thrown
  - Updates `driveApi` with the `DriveApi` returned from `createDriveApi`, which requires the `GoogleSignInAccount` from `account`
  - Gets the ID of the app's folder
    - On failing that, it creates a new folder called `BP Logger` in the root of the Google Drive
  - Gets the ID of the log file
    - On failing that, it creates a new Google Sheets file called `log` in the aforementioned app folder
    - It fills the file with the headers for the file's values
  - Gets the version number specfied in `pubspec.yaml` by using `PackageInfo`

## The HomePage

The HomePage consists of several large parts so this section is split into multiple subsections

### The Drawer

The drawer is specified in the `Scaffold`'s arguments.  
The drawer's width is enforced by a `Container` and determined by using `MediaQuery` to find out the devices width, and using <sup>3</sup>/<sub>4</sub> of that as the drawer width with a maximum of `280px`

The child of this `Container` is a `ListView` with `NeverScrollableScrollPhysics`
The `ListView`'s children are as follows:

- The Header
  - Consisting of a `Container` whose height is 80% of the `Drawer` width with a `DrawerHeader` as its child
  - The `DrawerHeader`'s child is a `Column` with a centered `CrossAxisAlignment`
  - The `Column`'s children consist of the following:
    - A `GoogleCircleUserAvatar` from `DriveHelper` with a height and width equal to the drawer width divided by 2.5 and padding of `10px`
    - The Google account's display name, enclosed in a `FittedBox` to allow the `Text` to scale down if needed and `headline4` text style
    - The Google account's email address, also enclosed in a `FittedBox`, with `headline6` text style
- The main buttons
  - These buttons are `ListTile`s with `Text` and a relevant `Icon`
  - There are 4 buttons as follows:
    - The `Log out` button with `Icons.logout` shows the `LogOutDialog` telling the user to click the log out button (which calls `DriveHelper.logOut`) then restart the app
    - The `Access file` button with `Icons.insert_drive_file_outlined` opens a link to the log file which can be viewed/edited in Google Sheets
    - The `Get support` button with `Icons.info_outline_rounded` open the BP Logger support page, which contains FAQs etc
    - The `About` button with `Icons.info_outline_rounded` displays an `AboutDialog` with information about the app, which includes
      - The app's name
      - The version of the app, from `DriveHelper.version`
      - A text span with a link to the app's Github page
      - A button that shows all the open source project's licences used by this app

### The main body

The main body consists of `TextFields` for the diastolic and systolic values to be entered
The body consists of the following widgets

- A row containing of
  - An empty `Container`
  - A `Text` that show the date chosen by the user (defaulting to today)
  - An edit `IconButton` that shows a `DatePicker` if clicked
- 2 nearly identical `TextFields` with
  - A maximum length of 3
  - A text size of `25px`
  - A `BorderSide` with a color of `AccentColor`
  - An input formatter that accepts `digitsOnly`
  - Keyboard types of `number`

### Floating action button

The FAB is the extended variant with the following arguments

- Icon of `Icons.storage`
- A label of `Add to file`
- The `onPressed` functions performs the following
  - Get the diastolic and systolic values from the `textFieldController`s
  - Check that they are not empty
  - Unfocus the current `FocusScope`
  - Construct the `String` required to be appended to the file
  - Show the `FileAppendDialog`, explained in a later section
  - Clear the `TextField`s using the `textFieldController`s

## FileAppendDialog

The `FileAppendDialog` is the dialog that shows when the file is being appended to.
The dialog returns a `FutureBuilder` with 3 states:

- Future resolved without errors
  - Show a title with `Success`
  - Show an animated green tick mark
  - A close button
- Future resolved with an error
  - Show a title with `Write failed`
  - Show a still red cross mark
  - A close button
- Future did not complete yet
  - Show a title with `Writing to file`
  - A `Container` of size 150<sup>2</sup> with a `CircularProgressIndicator`
