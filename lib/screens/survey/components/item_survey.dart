import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/models/question.dart';
import 'package:survey/screens/survey/components/answer.dart';
import 'package:provider/provider.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:survey/screens/survey/controllers/slider_score_controller.dart';
import 'list_pinned_file.dart';
import 'package:survey/models/response_list_campaign.dart';

class ItemSurvey extends StatefulWidget {
  const ItemSurvey({
    Key? key,
    required this.question,
    required this.questID,
    this.questionResultScheduleIdDto,
    required this.questionIndex,
    this.isCompleted = false,
  }) : super(key: key);
  final Questions question;
  final String questID;
  final bool isCompleted;
  final int questionIndex;
  final QuestionResultScheduleIdDto? questionResultScheduleIdDto;

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
        text: widget.questionResultScheduleIdDto != null
            ? widget.questionResultScheduleIdDto!.score.toString()
            : widget.question.maxScore.toString());
    textAnswerController = TextEditingController(
        text: widget.questionResultScheduleIdDto?.values?[0].label ?? "");
    noteAnswerController = TextEditingController(
        text: widget.questionResultScheduleIdDto != null
            ? widget.questionResultScheduleIdDto!.note ?? ""
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
                        values: widget.questionResultScheduleIdDto != null
                            ? widget.questionResultScheduleIdDto!.values != null
                                ? widget.questionResultScheduleIdDto!.values!
                                : []
                            : [])
                    : SinglechoiseAnswer(
                        polls: widget.question.poll!,
                        questID: widget.questID,
                        values: widget.questionResultScheduleIdDto != null
                            ? widget.questionResultScheduleIdDto!.values != null
                                ? widget.questionResultScheduleIdDto!.values!
                                : []
                            : [],
                      ),
              if (widget.question.type == "MULTIPLECHOOSE")
                widget.isCompleted
                    ? MultichoiseCompleted(
                        polls: widget.question.poll!,
                        values: widget.questionResultScheduleIdDto != null
                            ? widget.questionResultScheduleIdDto!.values != null
                                ? widget.questionResultScheduleIdDto!.values!
                                : []
                            : [])
                    : MultichoiseAnswer(
                        polls: widget.question.poll!,
                        questID: widget.questID,
                        values: widget.questionResultScheduleIdDto != null
                            ? widget.questionResultScheduleIdDto!.values != null
                                ? widget.questionResultScheduleIdDto!.values!
                                : []
                            : [],
                      ),
              Divider(
                thickness: 1,
              ),
              ScoreSlider(
                maxScore: widget.questionResultScheduleIdDto != null
                    ? widget.questionResultScheduleIdDto!.score
                    : widget.question.maxScore,
                index: widget.questionIndex,
                isReadOnly: widget.isCompleted,
              ),
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
                        .updateNoteAnswer(note: v, index: widget.questionIndex);
                  },
                  decoration: InputDecoration(labelText: "Ghi chú"),
                ),
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
                            .showSelectedFile(widget.questionIndex);
                      },
                      child: Text(S.current.choose_file)),
                ),
              widget.isCompleted
                  ? widget.questionResultScheduleIdDto != null
                      ? widget.questionResultScheduleIdDto!.media != null
                          ? ListPinnedFileComplete(
                              medias:
                                  widget.questionResultScheduleIdDto!.media!)
                          : Container()
                      : Container()
                  : ListPinnedFile(
                      questionIndex: widget.questionIndex,
                    ),
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
                      .answer
                      .resultsList
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
                      .answer
                      .resultsList
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
  }
}

class ScoreSlider extends StatelessWidget {
  const ScoreSlider(
      {Key? key,
      required this.maxScore,
      required this.index,
      this.isReadOnly = false})
      : super(key: key);

  final maxScore;
  final int index;
  final bool isReadOnly;
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
                                    .changeValue(val, index, context);
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
