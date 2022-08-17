import 'package:flutter/material.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/survey/models/model_answer.dart';

class AnswerController extends ChangeNotifier {
  Answer answer = Answer();
  List<ResultsList> _listResult = [];
  bool validation = false;
  AnswerController(
      {required String campaignId,
      required String scheduleId,
      required List<Questions> listQuestions,
      required List<QuestionResultScheduleIdDto>
          refQuestionResultScheduleIdDto}) {
    for (var i = 0; i < listQuestions.length; i++) {
      _listResult.add(ResultsList(
          sId: refQuestionResultScheduleIdDto.length > 0
              ? refQuestionResultScheduleIdDto
                  .firstWhere((element) =>
                      element.question?.questID == listQuestions[i].questID)
                  .sId
              : null,
          note: refQuestionResultScheduleIdDto.length > 0
              ? refQuestionResultScheduleIdDto
                  .firstWhere((element) =>
                      element.question?.questID == listQuestions[i].questID)
                  .note
              : "",
          score: refQuestionResultScheduleIdDto.length > 0
              ? refQuestionResultScheduleIdDto
                  .firstWhere((element) =>
                      element.question?.questID == listQuestions[i].questID)
                  .score
              : listQuestions[i].maxScore,
          media: refQuestionResultScheduleIdDto.length > 0
              ? refQuestionResultScheduleIdDto
                  .firstWhere((element) =>
                      element.question?.questID == listQuestions[i].questID)
                  .media
              : [],
          values: refQuestionResultScheduleIdDto.length > 0
              ? refQuestionResultScheduleIdDto
                  .firstWhere((element) =>
                      element.question?.questID == listQuestions[i].questID)
                  .values
                  ?.map((e) => Values(label: e.label))
                  .toList()
              : [],
          question: AQuestion(
              name: listQuestions[i].title,
              questID: listQuestions[i].questID,
              type: listQuestions[i].type,
              poll: listQuestions[i]
                  .poll
                  ?.map((e) => APoll(label: e.label))
                  .toList())));
    }
    answer = Answer(
        campaignId: campaignId,
        scheduleId: scheduleId,
        resultsList: _listResult);
  }

  updateLableAnswer(
      {required String lable, required String questID, required String type}) {
    switch (type) {
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

  updateScoreAnswer({required var score, required int index}) {
    answer.resultsList![index].score = score;
  }

  updateNoteAnswer({required String note, required int index}) {
    answer.resultsList![index].note = note;
  }

  addFileAnswer(
      {required String idFile, required String name, required int index}) {
    answer.resultsList![index].media!.add(Media(sId: idFile, name: name));
    print('answer: ' + answer.toString());
  }

  removeFileAnswer({required String idFile, required int index}) {
    answer.resultsList![index].media!
        .removeWhere((element) => element.sId == idFile);
  }

  /// Update lable
  void _updateLableAnswerText(String questID, String lable) {
    if ((answer.resultsList
                ?.firstWhere((element) => element.question?.questID == questID)
                .values
                ?.length ??
            0) >
        0) {
      answer.resultsList!
          .firstWhere((element) => element.question?.questID == questID)
          .values![0]
          .label = lable;
    } else {
      answer.resultsList
          ?.firstWhere((element) => element.question?.questID == questID)
          .values
          ?.add(Values(label: lable));
    }
  }

  void _updateLableAnswerSingleChoice(String questID, String lable) {
    _updateLableAnswerText(questID, lable);
  }

  void _updateLableMultiChoice(String questID, String lable) {
    if (answer.resultsList!
            .firstWhere((element) => element.question?.questID == questID)
            .values!
            .length >
        0) {
      if (answer.resultsList!
          .firstWhere((element) => element.question?.questID == questID)
          .values!
          .any((element) => element.label == lable)) {
        answer.resultsList!
            .firstWhere((element) => element.question?.questID == questID)
            .values!
            .removeWhere((element) => element.label == lable);
      } else {
        answer.resultsList!
            .firstWhere((element) => element.question?.questID == questID)
            .values!
            .add(Values(label: lable));
      }
    } else {
      answer.resultsList!
          .firstWhere((element) => element.question?.questID == questID)
          .values!
          .add(Values(label: lable));
    }
  }

  bool valid() {
    validation = true;
    notifyListeners();
    int v = 0;
    for (var i = 0; i < answer.resultsList!.length; i++) {
      if ((answer.resultsList?[i].values?.length ?? 0) > 0) {
        if (answer.resultsList![i].values!
            .every((element) => element.label!.isNotEmpty)) {
          v++;
        }
      }
    }
    return v == answer.resultsList!.length;
  }
}
