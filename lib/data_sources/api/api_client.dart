//import "package:dio/dio.dart" as dio;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as fileUtil;

typedef void OnUploadProgressCallback(int sentBytes, int totalBytes);

class ApiClient {
  static bool trustSelfSigned = true;
  late HttpClientRequest request;
  String? token;
  static HttpClient getHttpClient() {
    HttpClient httpClient = new HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }

  Future signInGoogle() async {
    const clientId =
        '658119356428-asfsjsu5j9snlfuci5ako3n956u2koeh.apps.googleusercontent.com';
    var googleSignIn = GoogleSignIn(
      clientId: clientId,
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
  }

  Future<String> upLoadFile(
      {required File file, OnUploadProgressCallback? onUploadProgress}) async {
    // final url = 'http://api.triples.hoasao.demego.vn/headless/stream/upload';
    final url =
        "https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart";

    final httpClient = getHttpClient();
    await signInGoogle();

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

    Stream<List<int>> streamUpload = msStream.transform(
      new StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
          byteCount += data.length;

          if (onUploadProgress != null) {
            onUploadProgress(byteCount, totalByteLength);

            // CALL STATUS CALLBACK;

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
