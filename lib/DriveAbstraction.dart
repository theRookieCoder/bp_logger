import 'package:google_sign_in/google_sign_in.dart'
    as signIn; // For signing in to Google
import 'package:googleapis/drive/v3.dart'
    as drive; // For accessing Google Drive
import 'GoogleAuthClient.dart';
import 'dart:convert';

class DriveAbstraction {
  static String logFileID;
  static String appFolderID;

  static Future<signIn.GoogleSignInAccount> signInWithGoogle(
      signIn.GoogleSignIn googleDriveSignIn) async {
    signIn.GoogleSignInAccount account =
        await googleDriveSignIn.signInSilently();
    if (account == null) {
      print("Silent sign in failed");
      account = await googleDriveSignIn.signIn();
    }
    return account;
  }

  static Future<drive.DriveApi> createDriveApi(account) async {
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);

    final driveApi = drive.DriveApi(authenticateClient);
    return driveApi;
  }

  static Future<void> init(drive.DriveApi driveApi) async {
    // IDs of the app's folder and the log file
    appFolderID = await getFileId(driveApi, "BP Logger");
    if (appFolderID == null) {
      print("BP Logger app folder not found. Creating BP Logger in root...");
      var driveFolder = new drive.File();
      driveFolder.name = "BP Logger";
      driveFolder.mimeType = "application/vnd.google-apps.folder";
      await driveApi.files.create(driveFolder);
      appFolderID = await getFileId(driveApi, "BP Logger");
    }

    logFileID = await getFileId(driveApi, "log");
    if (logFileID == null) {
      print("log.csv file not found. Creating log.csv in BP Logger...");
      var driveFile = new drive.File(); // Create new file
      driveFile.name = "log.csv"; // called log.csv
      driveFile.mimeType =
          "application/vnd.google-apps.file"; // mimeType of type file
      driveFile.parents = [appFolderID];

      final text = "Date, Time, Diastolic, Systolic";
      Stream<List<int>> mediaStream =
          Future.value(List.from(ascii.encode(text)).cast<int>().toList())
              .asStream()
              .asBroadcastStream();
      var media = new drive.Media(mediaStream, text.length);
      await driveApi.files
          .create(driveFile, uploadMedia: media); // and upload it to Drive
      logFileID = await getFileId(driveApi, "log");
    }

    print("Log file ID = $logFileID");
    print("App folder ID = $appFolderID");
  }

  static Future<String> getFileId(
      drive.DriveApi driveApi, String fileName) async {
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

  static Future<List<List<int>>> getFileData(
      drive.DriveApi driveApi, String fileID) async {
    drive.Media fileMedia = await driveApi.files.export(fileID, "text/csv",
        downloadOptions: drive.DownloadOptions
            .FullMedia); // Get contents of a Google Sheets file in csv format
    final dataStreamList =
        await fileMedia.stream.toList(); // Receive the Stream as List
    return dataStreamList; // return it
  }

  static Future<void> appendToFile(drive.DriveApi driveApi, String fileID,
      String text, List<int> filteredDataStreamList) async {
    final dataString =
        ascii.decode(filteredDataStreamList); // Decode List<int> to a String

    var placeholder = new drive.File(); // Placeholder file for update()
    Stream<List<int>> mediaStream = Future.value(
            List.from(ascii.encode("$dataString\n$text")).cast<int>().toList())
        .asStream()
        .asBroadcastStream(); // Add existing data and new text data, then make it into a Stream<List<int>> again
    var media = new drive.Media(
        mediaStream,
        dataString.length +
            text.length +
            "\n".length); // Make mediaStream into a drive.Media for sending
    await driveApi.files.update(placeholder, logFileID,
        uploadMedia: media); // Update the existing file with the new data
  }
}
