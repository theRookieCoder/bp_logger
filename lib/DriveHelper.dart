import 'GoogleAuthClient.dart' show GoogleAuthClient; // http stuff
import 'package:google_sign_in/google_sign_in.dart'
    show
        GoogleSignIn, // Google account
        GoogleSignInAccount, // Google sign in token (?)
        GoogleUserCircleAvatar; // Google avatar
import 'package:googleapis/drive/v3.dart'
    show DriveApi, File, Media, DownloadOptions; // For accessing Google Drive
import 'dart:convert' show ascii; // For encoding file
// For getting version number
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:url_launcher/url_launcher.dart' show launch;

class DriveHelper {
  String logFileID; // FileID of log file
  String appFolderID; // FileID of the folder the log file is in
  DriveApi driveApi; // Google Drive API
  GoogleSignInAccount account; // Google user account
  String version; // Version of app for about

  DriveHelper(GoogleSignInAccount recievedAccount) {
    account = recievedAccount;
  }

  GoogleUserCircleAvatar getAvatar() {
    return GoogleUserCircleAvatar(identity: account);
  }

  String getDisplayName() {
    return account.displayName;
  }

  String getEmail() {
    return account.email;
  }

  void showLogFile() {
    launch(
      "https://docs.google.com/spreadsheets/d/$logFileID/",
    );
  }

  static Future<GoogleSignInAccount> signInWithGoogle(
    GoogleSignIn googleDriveSignIn,
  ) async {
    // Silent sign in doesn't require user input
    GoogleSignInAccount account = await googleDriveSignIn.signInSilently();
    if (account == null) {
      print("Silent sign in failed");
      account = await googleDriveSignIn.signIn();
    }
    return account;
  }

  Future<DriveApi> createDriveApi(account) async {
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);

    final driveApi = DriveApi(authenticateClient);
    return driveApi;
  }

  Future<void> init() async {
    driveApi = await createDriveApi(account);
    // IDs of the app's folder and the log file
    appFolderID = await getFileId("BP Logger");
    if (appFolderID == null) {
      print("BP Logger app folder not found. Creating BP Logger in root...");
      var driveFolder = new File();
      driveFolder.name = "BP Logger";
      driveFolder.mimeType = "application/vnd.google-apps.folder";
      await driveApi.files.create(driveFolder);
      appFolderID = await getFileId("BP Logger");
    }

    logFileID = await getFileId("log");
    if (logFileID == null) {
      print("log.csv file not found. Creating log.csv in BP Logger...");
      var driveFile = new File(); // Create new file
      driveFile.name = "log.csv"; // called log.csv
      driveFile.mimeType =
          "application/vnd.google-apps.file"; // mimeType of file
      driveFile.parents = [appFolderID];

      final text = "Date, Time, Diastolic, Systolic";
      Stream<List<int>> mediaStream =
          Future.value(List.from(ascii.encode(text)).cast<int>().toList())
              .asStream()
              .asBroadcastStream();
      var media = new Media(mediaStream, text.length);
      await driveApi.files
          .create(driveFile, uploadMedia: media); // and upload it to Drive

      logFileID = await getFileId("log");
    }

    print("Log file ID = $logFileID");
    print("App folder ID = $appFolderID");
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      print("App version = $version");
    });
  }

  Future<String> getFileId(String fileName) async {
    // Get fileID of a file using its name
    final search = await driveApi.files.list(
        q: "name='$fileName' and trashed=false",
        spaces:
            'drive'); // Use name to search and make sure it isn't in the bin

    if (search.files.length == 0) {
      return null;
    }
    return search.files[0].id;
  }

  Future<String> exportFileData(String fileID) async {
    Media fileMedia = await driveApi.files
        .export(fileID, "text/csv", downloadOptions: DownloadOptions.fullMedia);

    String fileData;

    await fileMedia.stream.listen((event) {
      fileData = String.fromCharCodes(event);
    }).asFuture();
    return fileData;
  }

  Future<void> appendToFile(
    String fileID,
    String text,
  ) async {
    final dataString = await exportFileData(logFileID);

    final dataList =
        List.from(ascii.encode("$dataString\n$text")).cast<int>().toList();
    Stream<List<int>> mediaStream =
        Future.value(dataList).asStream().asBroadcastStream();
    var media = new Media(
      mediaStream,
      dataList.length,
    );
    await driveApi.files
        .update(new File(), logFileID, uploadMedia: media)
        .onError((error, stackTrace) {
      print("Error: $error was caught by DriveHelper");
      print("This was the stack trace when the exception was caught: ");
      print(stackTrace);
      return null;
    }); // Update the existing file with the new data
  }
}
