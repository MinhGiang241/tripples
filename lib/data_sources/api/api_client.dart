//import "package:dio/dio.dart" as dio;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path/path.dart' as fileUtil;
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:path/path.dart' as p;
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:survey/screens/survey/models/model_file.dart';
import '../../screens/survey/controllers/file_upload.dart';

typedef void OnUploadProgressCallback(int sentBytes, int totalBytes);

class ApiClient {
  static bool trustSelfSigned = true;
  late HttpClientRequest request;
  static String? token;
  static HttpClient getHttpClient() {
    HttpClient httpClient = new HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }

  static Future signInGoogle(file) async {
    // const clientId =
    //     '658119356428-asfsjsu5j9snlfuci5ako3n956u2koeh.apps.googleusercontent.com';
    const clientId =
        '658119356428-mvbf84qbti7lschvk3h7as8vr2qu21mm.apps.googleusercontent.com';
    try {
      var googleSignIn = GoogleSignIn(
        serverClientId: clientId,
        // clientId: isIOS ? googleClientIdIOS : null
        // clientId: clientId,
        scopes: [
          'email',
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/drive',
        ],
      );
      var user = await googleSignIn.signIn();
      final ggAuth = await user!.authentication;
      // ignore: unnecessary_null_comparison
      token = ggAuth.accessToken;
      var client = GoogleHttpClient(await user.authHeaders);
      var drive = ga.DriveApi(client);
      ga.File fileToUpload = ga.File();
      fileToUpload.name = p.basename(file.absolute.path);
      var response = await drive.files
          .create(
        fileToUpload,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
        ignoreDefaultVisibility: true,
        includePermissionsForView: 'published',
        // uploadOptions: commons.ResumableUploadOptions(),
      )
          .whenComplete(() {
        print('complete');
      });
      drive.permissions.create(
          ga.Permission(role: 'reader', type: 'anyone'), response.id as String);
      return ModelFile(
          index: 0,
          id: response.id as String,
          name: p.basename(file.absolute.path));
      // {'id': response.id, "name": p.basename(file.absolute.path)};
    } catch (e) {
      throw (e);
    }
  }

  Future<String> upLoadFile(
      {required File file,
      OnUploadProgressCallback? onUploadProgress,
      googleUpload,
      stopUpload,
      onFailUpload,
      setId}) async {
    // final url = 'http://api.triples.hoasao.demego.vn/headless/stream/upload';
    final url =
        "https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart";

    final httpClient = getHttpClient();
    // var FileUpload = await signInGoogle(file);

    print(token);
    request = await httpClient.postUrl(Uri.parse(url));

    int byteCount = 0;
    var multipart = await http.MultipartFile.fromPath(
      fileUtil.basename(file.path),
      file.path,
    );

    var requestMultipart = http.MultipartRequest("POST", Uri.parse(url));

    requestMultipart.files.add(multipart);

    var msStream = requestMultipart.finalize();

    var totalByteLength = requestMultipart.contentLength;

    request.contentLength = totalByteLength;

    request.headers.set(HttpHeaders.contentTypeHeader,
        requestMultipart.headers[HttpHeaders.contentTypeHeader]!);
    request.headers.set(HttpHeaders.authorizationHeader, "Bearer $token");
    var a = 0;

    Stream<List<int>> streamUpload = msStream.transform(
      new StreamTransformer.fromHandlers(
        handleData: (data, sink) async {
          sink.add(data);

          if (byteCount <= 0.7 * totalByteLength) {
            byteCount += data.length;
          }

          byteCount += data.length;

          try {
            if (onUploadProgress != null) {
              ++a;
              // throw ('Không tải được file');
              if (a == 1) {
                var result = await googleUpload();
                print(result.id);
                if (result.id != null && result.id != null) {
                  byteCount = totalByteLength;
                  setId(result.id);
                } else {
                  // close();
                  onFailUpload();
                  stopUpload(file);
                }
              }
              onUploadProgress(byteCount, totalByteLength);
              print("a: " + a.toString());
            }
          } catch (e) {
            onFailUpload();
          }
        },
        handleError: (error, stack, sink) {
          throw error;
        },
        handleDone: (sink) {
          sink.close();
          // UPLOAD DONE;
        },
      ),
    );

    await request.addStream(streamUpload);

    final httpResponse = await request.close();
    print(httpResponse);
    var statusCode = httpResponse.statusCode;

    if (statusCode ~/ 100 != 2) {
      return "";
    } else {
      return await readResponseAsString(httpResponse);
    }
  }

  Future<String> readResponseAsString(HttpClientResponse response) {
    var completer = new Completer<String>();
    var contents = new StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

  Future close() async {
    return request.abort();
  }
}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;
  Map<String, String> get header {
    return _headers;
  }

  GoogleHttpClient(this._headers) : super();
  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers!..addAll(_headers));
}
