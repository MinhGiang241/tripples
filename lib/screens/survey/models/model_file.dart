import 'dart:io';

import 'package:survey/data_sources/api/api_client.dart';

class ModelFile {
  final int index;
  final File? file;
  double? progress;
  String id;
  final ApiClient apiClient = ApiClient();
  ModelFile({required this.index, this.file, this.progress = 0, this.id = ""});

  Future uploadFile(Function(int, int) onUploadProgress) async {
    id = await apiClient.upLoadFile(
      file: file!,
      onUploadProgress: (sentBytes, totalBytes) {
        progress = sentBytes / totalBytes;
        onUploadProgress(sentBytes, totalBytes);
      },
    );
  }

  close() async {
    if (progress != 0) {
      await apiClient.close();
    }
  }
}
