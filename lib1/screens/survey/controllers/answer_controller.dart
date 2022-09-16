import 'package:flutter/material.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/survey/models/model_answer.dart';

class AnswerController extends ChangeNotifier {
  Answer? answer = Answer();
  List<ResultsList> listResult = [];
  bool validation = false;
  AnswerController(
      {required String campaignId,
      required String scheduleId,
      required List<Questions> listQuestions,
      required QuestionResult questionResults,
      required List<QuestionResultScheduleIdDto>
          refQuestionResultScheduleIdDto}) {
    if (questionResults.questions != null) {
      for (var i = 0; i < questionResults.questions!.length; i++) {
        var answer;
        if (questionResults.answers != null) {
          var answerIndex = questionResults.answers!.indexWhere((v) {
            return v.questionTemplateId == listQuestions[i].questID;
          });
          answer = questionResults.answers![answerIndex];
          listResult.add(new ResultsList(
            id: answer.id != null ? answer.id : "",
            questionTemplateId: listQuestions[i].questID,
            score: answer.score != null ? answer.score : 0,
            note: answer.note != null ? answer.note : "",
            answerText: answer.answerText != null ? answer.answerText : "",
            answerNumber:
                answer.answerNumber != null ? answer.answerNumber : "",
            scheduleId: answer.scheduleId != null ? answer.scheduleId : "",
            google_drive_ids:
                answer.gDriveLink != null ? answer.gDriveLink : "",
          ));
        } else {
          answer = new Answer();
          listResult.add(new ResultsList(
              id: '',
              score: 0,
              questionTemplateId: listQuestions[i].questID,
              answerText: '',
              answerNumber: null,
              note: '',
              scheduleId: scheduleId,
              google_drive_ids: ''));
        }
      }
    }
    print(listResult);
  }

  updateLableAnswer(
      {required String lable, required String questID, required String type}) {
    switch (type) {
      case "NUMBER":
        _updateLableAnswerNumber(questID, lable);
        break;
      case "TEXT":
        _updateLableAnswerText(questID, lable);
        break;
      case "SINGLECHOICE":
        _updateLableAnswerSingleChoice(questID, lable);
        break;
      case "MULTIPLECHOICE":
        _updateLableMultiChoice(questID, lable);
        break;
      default:
    }
  }

  updateScoreAnswer({required var score, required int index, questId}) {
    // print(score);
    // print(index);
    // print(questId);
    if (questId != null && questId != '') {
      var index = listResult
          .indexWhere((element) => element.questionTemplateId == questId);

      listResult[index].score = score;
    }
    print(listResult[index].score);
  }

  updateNoteAnswer({required String note, required questID}) {
    if (note != '') {
      var index = listResult
          .indexWhere((element) => element.questionTemplateId == questID);
      if (index >= 0) {
        listResult[index].note = note;
        print(listResult[index].note);
      }
    }
    // answer.data![index].note = note;
  }

  addFileAnswer(
      {required String idFile,
      required String name,
      required int index,
      questID}) {
    // answer!.data![index].media!.add(Media(sId: idFile, name: name));
    if (questID != null && questID != '') {
      var indexQuest = listResult
          .indexWhere((element) => element.questionTemplateId == questID);
      if (listResult[indexQuest].google_drive_ids != null) {
        listResult[indexQuest].google_drive_ids =
            listResult[indexQuest].google_drive_ids! +
                ',' +
                'https://drive.google.com/file/d/' +
                idFile;
      }

      if (listResult[index].google_drive_ids!.startsWith(',')) {
        listResult[index].google_drive_ids =
            listResult[index].google_drive_ids!.substring(
                  1,
                );
      }
    }
    print(listResult[index].google_drive_ids);
  }

  removeFileAnswer({required String idFile, required int index, questId}) {
    if (idFile != '') {
      var indexQuest = listResult
          .indexWhere((element) => element.questionTemplateId == questId);
      var linkList = listResult[indexQuest].google_drive_ids!.split(',');
      linkList.removeWhere((element) => element.contains(idFile));
      listResult[indexQuest].google_drive_ids = linkList.join(',');
      if (listResult[indexQuest].google_drive_ids!.startsWith(',')) {
        listResult[indexQuest].google_drive_ids!.substring(
              1,
            );
      }
      print(listResult[indexQuest].google_drive_ids);
    }

    // answer!.data![index].media!.removeWhere((element) => element.sId == idFile);
  }

  void _updateLableAnswerNumber(String questID, String? lable) {
    if (lable != null && lable != '') {
      var index = listResult
          .indexWhere((element) => element.questionTemplateId == questID);
      if (index >= 0 && double.tryParse(lable) != null) {
        listResult[index].answerNumber = double.parse(lable);
        print(listResult[index].answerNumber);
      }
    }
  }

  /// Update lable
  void _updateLableAnswerText(String questID, String? lable) {
    if (lable != null) {
      var index = listResult
          .indexWhere((element) => element.questionTemplateId == questID);
      if (index >= 0) {
        listResult[index].answerText = lable;
        print(listResult[index].answerText);
      }
    }
  }

  void _updateLableAnswerSingleChoice(String questID, String? lable) {
    _updateLableAnswerText(questID, lable);
  }

  void _updateLableMultiChoice(String questID, String? lable) {
    if (lable != null && lable != '') {
      var index = listResult
          .indexWhere((element) => element.questionTemplateId == questID);
      var listChoiceAnswer;

      listChoiceAnswer = listResult[index].answerText!.split('</br>');

      var choiceIndex = listChoiceAnswer.indexWhere((v) => v == lable);

      if (choiceIndex < 0) {
        listChoiceAnswer.add(lable);
        if (listChoiceAnswer.length == 1) {
          listResult[index].answerText = listChoiceAnswer[0];
        } else {
          listResult[index].answerText = listChoiceAnswer.join('</br>');
        }
      } else {
        listChoiceAnswer.removeWhere((v) => v == lable);
        if (listChoiceAnswer != null) {
          listResult[index].answerText = listChoiceAnswer.join('</br>');
        } else if (listChoiceAnswer.length == 1) {
          listResult[index].answerText = listChoiceAnswer[0];
        } else {
          listResult[index].answerText = null;
        }
      }
      if (listResult[index].answerText!.startsWith('</br>')) {
        listResult[index].answerText = listResult[index].answerText!.substring(
              5,
            );
      }
      print(listResult[index].answerText);
    }
  }

  bool valid() {
    return true;
    // validation = true;
    // notifyListeners();
    // int v = 0;
    // for (var i = 0; i < answer!.data!.length; i++) {
    //   if ((answer!.data?[i].values?.length ?? 0) > 0) {
    //     if (answer!.data![i].values!
    //         .every((element) => element.label!.isNotEmpty)) {
    //       v++;
    //     }
    //   }
    // }
    // return v == answer!.data!.length;
  }
}
