import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/models/model_file.dart';

class FileUploadController extends ChangeNotifier {
  bool isUploading = false;
  List<ModelFile> listModelFile = [];
  FileUploadController(
      List<QuestionResultScheduleIdDto> refQuestionResultScheduleIdDto) {
    for (var i = 0; i < refQuestionResultScheduleIdDto.length; i++) {
      if (refQuestionResultScheduleIdDto[i].media != null) {
        for (var j = 0;
            j < refQuestionResultScheduleIdDto[i].media!.length;
            j++) {
          listModelFile.add(ModelFile(
              index: i,
              file: File(
                  "s/${refQuestionResultScheduleIdDto[i].media![j].name ?? 's/File'}"),
              progress: 1,
              id: refQuestionResultScheduleIdDto[i].media![j].sId ?? ""));
        }
      }
    }
  }
  addFile(List<ModelFile> list) {
    listModelFile.addAll(list);
    notifyListeners();
  }

  Future uploadFile(
      BuildContext context, File file, Function uploadGoogle) async {
    isUploading = true;
    notifyListeners();

    print(listModelFile);

    var uploadFile =
        listModelFile.firstWhere((element) => element.file! == file);
    print(uploadFile);
    try {
      await uploadFile.uploadFile((byte, totalByte) {
        notifyListeners();
      }, uploadGoogle);
    } catch (e) {
      closeUpload(file);
    }

    for (var i = 0; i < listModelFile.length; i++) {
      if (listModelFile[i].id.isNotEmpty) {
        if (listModelFile[i].file == file) {
          Provider.of<AnswerController>(context, listen: false).addFileAnswer(
              idFile: listModelFile[i].id,
              name: listModelFile[i].file!.path.split("/").last,
              index: listModelFile[i].index);
        }
      }
    }

    //
    isUploading = false;
    notifyListeners();
  }

  Future closeUpload(File file) async {
    await listModelFile.firstWhere((element) => element.file! == file).close();
    listModelFile.removeWhere((element) => element.file == file);
    notifyListeners();
  }
}
