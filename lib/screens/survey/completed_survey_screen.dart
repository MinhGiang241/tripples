import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';

import 'package:survey/generated/l10n.dart';
import 'package:survey/models/question.dart';

import 'package:survey/screens/survey/controllers/file_upload.dart';

import 'components/item_survey.dart';
import 'models/model_file.dart';
import 'package:survey/models/response_list_campaign.dart';

class CompletedSurveyScreen extends StatelessWidget {
  final List<Questions> questions;
  final List<QuestionResultScheduleIdDto> questionResultScheduleIdDto;
  const CompletedSurveyScreen({
    Key? key,
    required this.questions,
    required this.questionResultScheduleIdDto,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.current.survey,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              //height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: EdgeInsets.only(bottom: padding * 4),
                child: Column(
                  children: List.generate(
                      questionResultScheduleIdDto.length >= questions.length
                          ? questions.length
                          : questionResultScheduleIdDto.length,
                      (index) => ItemSurvey(
                            orderNum: index + 1,
                            question: questions[index],
                            questionIndex: index,
                            questID: questions[index].questID ?? "",
                            questionResultScheduleIdDto:
                                questionResultScheduleIdDto[index],
                          )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // onUpload(BuildContext context, List<ModelFile> listModelFile) async {
  //   for (int i = 0; i < listModelFile.length; i++) {
  //     await Provider.of<FileUploadController>(context, listen: false)
  //         .uploadFile(context, listModelFile[i].file!);
  //   }
  // }
}
