import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/screens/survey/controllers/file_upload.dart';
import 'package:survey/screens/survey/models/model_file.dart';

enum TypeOfFile { media, file }

class ChooseFileController extends ChangeNotifier {
  List<ModelFile> listPinnedFile = [];
  List<ModelFile> files = [];
  String? questID;
  int? currentIndex;
  bool isSelectedFile = false;
  bool isUploadFile = false;

  showSelectedFile(int index, questIditem) {
    questID = questIditem;
    currentIndex = index;
    isSelectedFile = true;
    notifyListeners();
  }

  showUploadFile(int index) {
    currentIndex = index;
    isUploadFile = true;
    notifyListeners();
  }

  offSelectFile() {
    isSelectedFile = false;
    notifyListeners();
  }

  offUploadFile() {
    isUploadFile = false;
    isSelectedFile = false;
    currentIndex = null;
    notifyListeners();
  }

  chooseMediaFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
    );

    if (result != null) {
      files = result.paths
          .map((path) => ModelFile(
              index: currentIndex!, file: File(path!), questID: questID))
          .toList();
      Provider.of<FileUploadController>(context, listen: false).addFile(files);
      showUploadFile(currentIndex!);
    } else {
      //listPinnedFile = [];
    }
    notifyListeners();
  }

  chooseFileCustom(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'docx',
          'doc',
          'zip',
          'rar',
          'xls',
          'xlsx',
          'xlsm'
        ]);

    if (result != null) {
      files = result.paths
          .map((path) => ModelFile(
                index: currentIndex!,
                file: File(path!),
              ))
          .toList();

      Provider.of<FileUploadController>(context, listen: false).addFile(files);
      showUploadFile(currentIndex!);
    } else {
      //listPinnedFile = [];
    }
    notifyListeners();
  }

  removeFile(File file) async {
    listPinnedFile.removeWhere((element) => element.file == file);

    notifyListeners();
  }
}

extension MediaString on String {
  bool isImage() {
    String s = this.toLowerCase();
    return s.endsWith(".jpg") ||
        s.endsWith(".jpeg") ||
        s.endsWith(".png") ||
        s.endsWith(".gif") ||
        s.endsWith(".bmp");
  }

  bool isVideo() {
    String s = this.toLowerCase();
    return s.endsWith(".mp4") ||
        s.endsWith(".avi") ||
        s.endsWith(".wmv") ||
        s.endsWith(".rmvb") ||
        s.endsWith(".mpg") ||
        s.endsWith(".mpeg") ||
        s.endsWith(".3gp");
  }

  bool isFile() {
    String s = this.toLowerCase();
    return s.endsWith(".docx") ||
        s.endsWith(".doc") ||
        s.endsWith(".zip") ||
        s.endsWith(".rar") ||
        s.endsWith(".xls") ||
        s.endsWith(".xlsx") ||
        s.endsWith(".xlsm");
  }
}
