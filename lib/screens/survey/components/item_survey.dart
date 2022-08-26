import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/models/question.dart';
import 'package:survey/screens/survey/components/answer.dart';
import 'package:provider/provider.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:survey/screens/survey/controllers/slider_score_controller.dart';
import 'gdrive_link.dart';
import 'list_pinned_file.dart';
import 'package:survey/models/response_list_campaign.dart';

class ItemSurvey extends StatefulWidget {
  const ItemSurvey({
    Key? key,
    required this.question,
    required this.questID,
    this.questionResultScheduleIdDto,
    required this.questionIndex,
    this.questionResult,
    this.isCompleted = false,
  }) : super(key: key);
  final Questions question;
  final String questID;
  final bool isCompleted;
  final int questionIndex;
  final QuestionResultScheduleIdDto? questionResultScheduleIdDto;
  final Answers? questionResult;

  @override
  ItemSurveyState createState() => ItemSurveyState();
}

class ItemSurveyState extends State<ItemSurvey> {
  late TextEditingController scoreController;
  late TextEditingController textAnswerController;
  late TextEditingController noteAnswerController;
  @override
  void initState() {
    super.initState();
    scoreController = TextEditingController(
        text: widget.questionResult != null
            ? widget.questionResult!.score.toString()
            : widget.question.maxScore.toString());
    textAnswerController = TextEditingController(
        text: widget.question.type == "TEXT"
            ? widget.questionResult?.answer
            : widget.question.type == "NUMBER"
                ? widget.questionResult?.answer.toString()
                : "");
    noteAnswerController = TextEditingController(
        text: widget.questionResult != null
            ? widget.questionResult!.note ?? ""
            : "");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                child: Text(
                  widget.question.title ?? "",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(
                height: padding / 2,
              ),
              if (!widget.isCompleted)
                if (valiation(context))
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                    child: Text(
                      "* Đây là trường bắt buộc",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: padding * 1.5, vertical: 5),
                child: Text(
                  widget.question.hint ?? "",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ),
              if (widget.question.type == "TEXT")
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                  child: TextField(
                    controller: textAnswerController,
                    readOnly: widget.isCompleted,
                    decoration: InputDecoration(labelText: "Trả lời"),
                    onChanged: (v) {
                      Provider.of<AnswerController>(context, listen: false)
                          .updateLableAnswer(
                              lable: v,
                              questID: widget.questID,
                              type: widget.question.type!);
                    },
                  ),
                ),
              if (widget.question.type == "NUMBER")
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                  child: TextField(
                    controller: textAnswerController,
                    readOnly: widget.isCompleted,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Trả lời"),
                    onChanged: (v) {
                      Provider.of<AnswerController>(context, listen: false)
                          .updateLableAnswer(
                              lable: v,
                              questID: widget.questID,
                              type: widget.question.type!);
                    },
                  ),
                ),
              if (widget.question.type == "ONECHOOSE")
                widget.isCompleted
                    ? SinglechoiseCompleted(
                        polls: widget.question.poll!,
                        values: widget.questionResult != null
                            ? widget.questionResult!.answer != null
                                ? widget.questionResult!.answer!
                                : ""
                            : "")
                    : SinglechoiseAnswer(
                        polls: widget.question.poll!,
                        questID: widget.questID,
                        values: widget.questionResult != null
                            ? widget.questionResult!.answer != null
                                ? widget.questionResult!.answer!
                                : ""
                            : "",
                      ),
              if (widget.question.type == "MULTIPLECHOOSE")
                widget.isCompleted
                    ? MultichoiseCompleted(
                        polls: widget.question.poll!,
                        values: widget.questionResult != null
                            ? widget.questionResult!.answer != null
                                ? widget.questionResult!.answer!.split(',')
                                : []
                            : [])
                    : MultichoiseAnswer(
                        polls: widget.question.poll!,
                        questID: widget.questID,
                        values: widget.questionResult != null
                            ? widget.questionResult!.answer is String
                                ? widget.questionResult!.answer
                                : ""
                            : "",
                      ),
              Divider(
                thickness: 1,
              ),
              ScoreSlider(
                  maxScore: widget.questionResult != null
                      ? widget.questionResult!.score
                      : widget.question.maxScore,
                  index: widget.questionIndex,
                  isReadOnly: widget.isCompleted,
                  questID: widget.questID),
              Divider(
                thickness: 1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                child: TextField(
                  controller: noteAnswerController,
                  readOnly: widget.isCompleted,
                  minLines: 1,
                  maxLines: 5,
                  onChanged: (v) {
                    Provider.of<AnswerController>(context, listen: false)
                        .updateNoteAnswer(note: v, questID: widget.questID);
                  },
                  decoration: InputDecoration(labelText: "Ghi chú"),
                ),
              ),
              Divider(
                thickness: 1,
              ),
              SizedBox(
                height: padding / 2,
              ),
              if (!widget.isCompleted)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                  child: ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                      onPressed: () {
                        Provider.of<ChooseFileController>(context,
                                listen: false)
                            .showSelectedFile(
                                widget.questionIndex, widget.questID);
                      },
                      child: Text(S.current.choose_file)),
                ),
              // widget.isCompleted
              //     ? widget.questionResult != null
              //         ? widget.questionResultScheduleIdDto!.media != null
              //             ? ListPinnedFileComplete(
              //                 medias:
              //                     widget.questionResultScheduleIdDto!.media!)
              //             : Container()
              //         : Container()
              //     :
              Divider(
                thickness: 1,
              ),
              GdriveLinkListPin(
                questId: widget.questID,
                Index: widget.questionIndex,
                questionResult: widget.questionResult,
              ),
              ListPinnedFile(
                  questionResult: widget.questionResult,
                  questionIndex: widget.questionIndex,
                  questId: widget.questID),
            ],
          ),
        ),
        Divider(
          thickness: padding / 2,
        ),
      ],
    );
  }

  bool valiation(BuildContext context) {
    // return true;
    try {
      print(context.watch<AnswerController>());

      if (context.watch<AnswerController>().validation) {
        switch (widget.question.type) {
          case "TEXT":
            if (textAnswerController.text.isEmpty) {
              return true;
            } else {
              return false;
            }
          case "SINGLECHOICE":
            if ((context
                        .watch<AnswerController>()
                        .answer!
                        .data
                        ?.firstWhere((element) =>
                            element.question?.questID == widget.questID)
                        .values
                        ?.length ??
                    0) >
                0) {
              return false;
            } else {
              return true;
            }

          case "MULTIPLECHOICE":
            if ((context
                        .watch<AnswerController>()
                        .answer!
                        .data
                        ?.firstWhere((element) =>
                            element.question?.questID == widget.questID)
                        .values
                        ?.length ??
                    0) >
                0) {
              return false;
            } else {
              return true;
            }
          default:
            return false;
        }
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }
}

class ScoreSlider extends StatelessWidget {
  const ScoreSlider(
      {Key? key,
      required this.maxScore,
      required this.index,
      required this.questID,
      this.isReadOnly = false})
      : super(key: key);

  final maxScore;
  final int index;
  final bool isReadOnly;
  final String questID;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SliderScoreController>(
        create: (_) => SliderScoreController(
            double.parse(maxScore != null ? maxScore.toString() : "0")),
        builder: (context, child) {
          double value = context.watch<SliderScoreController>().value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                child: Text("Điểm",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontSize: 16,
                        )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    if (!isReadOnly)
                      Expanded(
                        child: Slider.adaptive(
                            activeColor: Theme.of(context).primaryColor,
                            value: value,
                            divisions: 20,
                            label: "$value",
                            max: 10,
                            min: 0,
                            onChanged: (val) {
                              if (!isReadOnly) {
                                Provider.of<SliderScoreController>(context,
                                        listen: false)
                                    .changeValue(val, index, context, questID);
                              }
                            }),
                      ),
                    SizedBox(
                      width: 14,
                    ),
                    Text(
                      "$value",
                      style: TextStyle(height: 1.5, fontSize: 16),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class SelectFileButton extends StatelessWidget {
  const SelectFileButton({
    Key? key,
    required this.iconData,
    required this.color,
    required this.title,
    required this.onPressed,
  }) : super(key: key);
  final IconData iconData;
  final Color color;
  final String title;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 60, minHeight: 60),
          child: ElevatedButton(
              onPressed: () {
                onPressed();
              },
              style: TextButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: color.withOpacity(0.1)),
              child: Icon(
                iconData,
                color: color,
              )),
        ),
        SizedBox(
          height: padding,
        ),
        Text(title, style: Theme.of(context).textTheme.bodyText2)
      ],
    );
  }
}
