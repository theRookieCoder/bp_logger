import 'package:google_sign_in/google_sign_in.dart' as signIn; // For signing in to Google
import 'package:googleapis/drive/v3.dart' as drive; // For accessing Google Drive
import 'GoogleAuthClient.dart';
import 'dart:convert';
import 'dart:async';

class DriveAbstraction {
  static String logFileID;
  static String appFolderID;

  static Future<drive.DriveApi> createDriveApi() async {
    final googleDriveSignIn = signIn.GoogleSignIn.standard(
        scopes: [
          drive.DriveApi.DriveFileScope
        ]); // Sign in to Google with Google Drive access
    final signIn.GoogleSignInAccount account = await googleDriveSignIn
        .signIn(); // Actually sign in

    // Really don't understand the following code
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);

    final driveApi = drive.DriveApi(authenticateClient);
    return driveApi;
  }

  static Future<void> init(drive.DriveApi driveApi) async {// IDs of the app's folder and the log file

    if (await getFileId(driveApi, "BP Logger") == null) {
      print("BP Logger app folder not found. Creating BP Logger in root...");
      var driveFolder = new drive.File();
      driveFolder.name = "BP Logger";
      driveFolder.mimeType = "application/vnd.google-apps.folder";
      await driveApi.files.create(driveFolder);
    }
    appFolderID = await getFileId(driveApi, "BP Logger");

    if (await getFileId(driveApi, "log") == null) {
      print("log.csv file not found. Creating log.csv in BP Logger...");
      var driveFile = new drive.File(); // Create new file
      driveFile.name = "log.csv"; // called log.csv
      driveFile.mimeType = "application/vnd.google-apps.file"; // mimeType of type file
      driveFile.parents = [appFolderID];

      final text = "Date, Time, Diastolic, Systolic";
      Stream<List<int>> mediaStream = Future.value(List.from(ascii.encode(text)).cast<int>().toList()).asStream().asBroadcastStream();
      var media = new drive.Media(mediaStream, text.length);
      await driveApi.files.create(driveFile, uploadMedia: media); // and upload it to Drive
    }
    logFileID = await getFileId(driveApi, "log");

    print("Log file ID = $logFileID");
    print("App folder ID = $appFolderID");
  }

  static Future<String> getFileId(drive.DriveApi driveApi, String fileName) async {
    // Get fileID of file using its name
    final search = await driveApi.files.list(q: "name='$fileName' and trashed=false", spaces: 'drive');

    if (search.files.length == 0) {
      return null;
    }
    return search.files[0].id;
  }

  static Future<void> appendToFile(drive.DriveApi driveApi, String fileID, String text) async {
    drive.Media fileMedia = await driveApi.files.export(fileID, "text/csv", downloadOptions: drive.DownloadOptions.FullMedia); // Get contents of Google Docs file
    final dataStreamList = await fileMedia.stream.toList(); // Receive Stream as List
    List<int> filteredDataStreamList = [];

    for (var i in dataStreamList) {
      for (var j in i) {
        filteredDataStreamList.add(j);
      }
    }
    print(filteredDataStreamList);

    final dataString = ascii.decode(filteredDataStreamList); // Decode List<int> to String

    var placeholder = new drive.File(); // Placeholder file for update()
    Stream<List<int>> mediaStream = Future.value(List.from(ascii.encode("$dataString\n$text")).cast<int>().toList()).asStream().asBroadcastStream(); // Add existing data and new text data then make into a Stream<List<int>>
    var media = new drive.Media(mediaStream, dataString.length + text.length + "\n".length); // Make mediaStream into drive.Media
    await driveApi.files.update(placeholder, logFileID, uploadMedia: media); // Update existing file with new data
    print("Successfully wrote:\n$dataString $text");
  }
}
