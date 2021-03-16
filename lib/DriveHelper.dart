import 'package:bp_logger/FileLocationDialog.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show
        GoogleSignIn,
        GoogleSignInAccount,
        GoogleUserCircleAvatar; // For signing in to Google
import 'package:googleapis/drive/v3.dart'
    show DriveApi, File, Media, DownloadOptions; // For accessing Google Drive
import 'GoogleAuthClient.dart';
import 'dart:convert' show ascii;

class DriveHelper {
  String logFileID;
  String appFolderID;
  DriveApi driveApi;
  GoogleSignInAccount account;

  DriveHelper(GoogleSignInAccount recievedAccount) {
    account = recievedAccount;
    instantiateApi();
  }

  instantiateApi() async {
    // Create an instance of the Drive API using Google account
    driveApi = await createDriveApi(account);
    init();
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

  getFileLocationDialog() {
    return FileLocationDialog(fileId: logFileID);
  }

  static Future<GoogleSignInAccount> signInWithGoogle(
      GoogleSignIn googleDriveSignIn) async {
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

  Future<List<List<int>>> getFileData(String fileID) async {
    Media fileMedia = await driveApi.files.export(fileID, "text/csv",
        downloadOptions: DownloadOptions
            .FullMedia); // Get contents of a Google Sheets file in csv format
    final dataStreamList =
        await fileMedia.stream.toList(); // Receive the Stream as List
    return dataStreamList; // return it
  }

  Future<void> appendToFile(
    String fileID,
    String text,
  ) async {
    List<int> filteredDataStreamList = [];

    final dataStreamList = await getFileData(logFileID);

    if (dataStreamList.length > 1) {
      for (var i in dataStreamList) {
        filteredDataStreamList.addAll(i);
      }
    } else {
      filteredDataStreamList = dataStreamList[0];
    }

    final dataString =
        ascii.decode(filteredDataStreamList); // Decode List<int> to a String

    var placeholder = new File(); // Placeholder file for update()
    Stream<List<int>> mediaStream = Future.value(
            List.from(ascii.encode("$dataString\n$text")).cast<int>().toList())
        .asStream()
        .asBroadcastStream(); // Add existing data and new text data, then make it into a Stream<List<int>> again
    var media = new Media(
        mediaStream,
        dataString.length +
            text.length +
            "\n".length); // Make mediaStream into a Media for sending
    await driveApi.files.update(placeholder, logFileID,
        uploadMedia: media); // Update the existing file with the new data
  }
}
