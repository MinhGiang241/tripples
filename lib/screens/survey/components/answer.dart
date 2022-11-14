import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/multichoise_controller.dart';
import 'package:survey/screens/survey/controllers/single_choise_controller.dart';

import '../../../constants.dart';

enum AnswerType { text, singleChoise, multiChoise }

class MultichoiseAnswer extends StatelessWidget {
  MultichoiseAnswer(
      {Key? key,
      required this.polls,
      required this.questID,
      required this.values,
      required this.validation,
      required this.question,
      required this.isAutoScore,
      this.choiceScore,
      this.score = 0})
      : super(key: key);
  final List<Poll> polls;
  final String questID;
  final String? values;
  final Function validation;
  final Questions question;
  final bool isAutoScore;
  final Function(String)? choiceScore;
  double score;

  @override
  Widget build(BuildContext context) {
    // var listData;
    // try {
    // listData = context.read<MultichoiseController>().listData.length;
    // } catch (_) {
    //   listData = 0;
    // }
    // print(polls);
    // print(questID);
    // print(values);
    return ChangeNotifierProvider<MultichoiseController>(
      create: (context) => MultichoiseController(polls, values),
      builder: (context, child) => Column(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  context.read<MultichoiseController>().listData.length,
                  (index) => CheckboxListTile(
                        activeColor: Theme.of(context).primaryColor,
                        value: context
                            .watch<MultichoiseController>()
                            .listData[index]
                            .isSelected,
                        onChanged: (val) {
                          Provider.of<MultichoiseController>(context,
                                  listen: false)
                              .onChange(index, val!,
                                  isAutoScore ? choiceScore : null);

                          score = Provider.of<MultichoiseController>(context,
                                  listen: false)
                              .value;
                          Provider.of<AnswerController>(context, listen: false)
                              .updateLableAnswer(
                                  lable: context
                                      .read<MultichoiseController>()
                                      .listData[index]
                                      .label!,
                                  questID: questID,
                                  type: "MULTIPLECHOICE");
                          validation(context);
                        },
                        title: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            Text(context
                                    .watch<MultichoiseController>()
                                    .listData[index]
                                    .label ??
                                ''),
                            if (isAutoScore)
                              Text(
                                ' (${context.watch<MultichoiseController>().listData[index].score} điểm)',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              )
                          ],
                        ),

                        // Text(context
                        //             .watch<MultichoiseController>()
                        //             .listData[index]
                        //             .label !=
                        //         null
                        //     ? (context
                        //                 .watch<MultichoiseController>()
                        //                 .listData[index]
                        //                 .score !=
                        //             null)
                        //         ? '${context.watch<MultichoiseController>().listData[index].label} - (${context.watch<MultichoiseController>().listData[index].score} đ)'
                        //         : '${context.watch<MultichoiseController>().listData[index].label}'
                        //     : ""),
                        controlAffinity: ListTileControlAffinity.leading,
                      ))),
          !question.valid
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                  child: Text(
                    "Đây là câu hỏi bắt buộc vui lòng chọn đáp án",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(),
                )
        ],
      ),
    );
  }
}

class MultichoiseCompleted extends StatelessWidget {
  const MultichoiseCompleted({
    Key? key,
    required this.polls,
    required this.values,
  }) : super(key: key);
  final List<Poll> polls;
  final List<String> values;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            polls.length,
            (index) => CheckboxListTile(
                  activeColor: Theme.of(context).primaryColor,
                  value: values.any((element) => element == polls[index].label),
                  onChanged: (val) {},
                  title: Text(polls[index].label ?? ""),
                  controlAffinity: ListTileControlAffinity.leading,
                )));
  }
}

class SinglechoiseAnswer extends StatelessWidget {
  const SinglechoiseAnswer({
    Key? key,
    required this.polls,
    required this.questID,
    required this.values,
    required this.validation,
    required this.questions,
    required this.isAutoScore,
    required this.choiceScore,
  }) : super(key: key);
  final List<Poll> polls;
  final String questID;
  final String values;
  final Function validation;
  final Questions questions;
  final bool isAutoScore;
  final Function(String)? choiceScore;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SingleChoiseController>(
      create: (_) =>
          SingleChoiseController(polls, values.length > 0 ? values : null),
      builder: (context, child) => Column(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
                context.watch<SingleChoiseController>().listData.length,
                (index) => RadioListTile<Poll>(
                      activeColor: Theme.of(context).primaryColor,
                      groupValue: context.watch<SingleChoiseController>().data,
                      value: context
                          .watch<SingleChoiseController>()
                          .listData[index],
                      toggleable: true,
                      onChanged: (val) {
                        Provider.of<SingleChoiseController>(context,
                                listen: false)
                            .onChange(val, isAutoScore ? choiceScore : null);

                        Provider.of<AnswerController>(context, listen: false)
                            .updateLableAnswer(
                                lable: val != null ? val.label! : '',
                                questID: questID,
                                type: "SINGLECHOICE");
                        validation(context);
                      },
                      title: Wrap(
                        children: [
                          Text(context
                                  .watch<SingleChoiseController>()
                                  .listData[index]
                                  .label ??
                              ""),
                          if (isAutoScore)
                            Text(
                              ' (${context.watch<SingleChoiseController>().listData[index].score} điểm)',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            )
                        ],
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ))),
        !questions.valid
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: padding * 1.5),
                child: Text(
                  "Đây là câu hỏi bắt buộc vui lòng chọn đáp án",
                  style: TextStyle(color: Colors.red),
                ),
              )
            : Padding(padding: EdgeInsets.symmetric())
      ]),
    );
  }
}

class SinglechoiseCompleted extends StatefulWidget {
  const SinglechoiseCompleted({
    Key? key,
    required this.polls,
    required this.values,
  }) : super(key: key);
  final List<Poll> polls;
  final String? values;

  @override
  _SinglechoiseCompletedState createState() => _SinglechoiseCompletedState();
}

class _SinglechoiseCompletedState extends State<SinglechoiseCompleted> {
  late List<Poll> polls;
  var choice = [];
  @override
  void initState() {
    super.initState();

    polls = widget.polls;
    int x = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(polls.length, (index) {
          return RadioListTile<Poll>(
            activeColor: Theme.of(context).primaryColor,
            groupValue: widget.values!.length > 0
                ? widget.polls
                    .firstWhere((element) => element.label == widget.values)
                : Poll(),
            value: widget.polls[index],
            onChanged: (val) {},
            title: Text(polls[index].label ?? ""),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }));
  }
}
