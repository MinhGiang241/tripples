//import "package:dio/dio.dart" as dio;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as fileUtil;

typedef void OnUploadProgressCallback(int sentBytes, int totalBytes);

class ApiClient {
  static bool trustSelfSigned = true;
  late HttpClientRequest request;

  static HttpClient getHttpClient() {
    HttpClient httpClient = new HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }

  Future<String> upLoadFile(
      {required File file, OnUploadProgressCallback? onUploadProgress}) async {
    final url = 'http://api.triples.hoasao.demego.vn/headless/stream/upload';

    final httpClient = getHttpClient();

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
//
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
