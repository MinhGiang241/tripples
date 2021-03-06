import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/multichoise_controller.dart';
import 'package:survey/screens/survey/controllers/single_choise_controller.dart';

enum AnswerType { text, singleChoise, multiChoise }

class MultichoiseAnswer extends StatelessWidget {
  const MultichoiseAnswer({
    Key? key,
    required this.polls,
    required this.questID,
    required this.values,
  }) : super(key: key);
  final List<Poll> polls;
  final String questID;
  final List<HValues> values;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MultichoiseController>(
      create: (context) => MultichoiseController(polls, values),
      builder: (context, child) => Column(
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
                      Provider.of<MultichoiseController>(context, listen: false)
                          .onChange(index, val!);
                      Provider.of<AnswerController>(context, listen: false)
                          .updateLableAnswer(
                              lable: context
                                  .read<MultichoiseController>()
                                  .listData[index]
                                  .label!,
                              questID: questID,
                              type: "MULTIPLECHOICE");
                    },
                    title: Text(context
                            .watch<MultichoiseController>()
                            .listData[index]
                            .label ??
                        ""),
                    controlAffinity: ListTileControlAffinity.leading,
                  ))),
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
  final List<HValues> values;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            polls.length,
            (index) => CheckboxListTile(
                  activeColor: Theme.of(context).primaryColor,
                  value: values
                      .any((element) => element.label == polls[index].label),
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
  }) : super(key: key);
  final List<Poll> polls;
  final String questID;
  final List<HValues> values;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SingleChoiseController>(
      create: (_) =>
          SingleChoiseController(polls, values.length > 0 ? values[0] : null),
      builder: (context, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
              context.watch<SingleChoiseController>().listData.length,
              (index) => RadioListTile<Poll>(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: context.watch<SingleChoiseController>().data,
                    value:
                        context.watch<SingleChoiseController>().listData[index],
                    onChanged: (val) {
                      Provider.of<SingleChoiseController>(context,
                              listen: false)
                          .onChange(val!);
                      Provider.of<AnswerController>(context, listen: false)
                          .updateLableAnswer(
                              lable: val.label!,
                              questID: questID,
                              type: "SINGLECHOICE");
                    },
                    title: context
                                .watch<SingleChoiseController>()
                                .listData[index]
                                .label ==
                            "Kh??c"
                        ? TextField(
                            focusNode: context
                                .watch<SingleChoiseController>()
                                .otherNode,
                            onChanged: (v) {
                              Provider.of<SingleChoiseController>(context,
                                      listen: false)
                                  .changeLableAnother(v);
                              Provider.of<AnswerController>(context,
                                      listen: false)
                                  .updateLableAnswer(
                                      lable: v,
                                      questID: questID,
                                      type: "SINGLECHOICE");
                            },
                            decoration: InputDecoration(hintText: "Kh??c"),
                          )
                        : Text(context
                                .watch<SingleChoiseController>()
                                .listData[index]
                                .label ??
                            ""),
                    controlAffinity: ListTileControlAffinity.leading,
                  ))),
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
  final List<HValues> values;

  @override
  _SinglechoiseCompletedState createState() => _SinglechoiseCompletedState();
}

class _SinglechoiseCompletedState extends State<SinglechoiseCompleted> {
  late List<Poll> polls;
  @override
  void initState() {
    super.initState();
    polls = widget.polls;
    int x = 0;
    for (var i = 0; i < widget.polls.length; i++) {
      if (widget.values.length > 0) {
        if (widget.polls[i].label == widget.values[0].label) {
          x++;
        }
      }
    }
    if (x == 0) {
      if (widget.values.length > 0) {
        polls.add(Poll(label: widget.values[0].label));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(polls.length, (index) {
          return RadioListTile<Poll>(
            activeColor: Theme.of(context).primaryColor,
            groupValue: widget.values.length > 0
                ? widget.polls.firstWhere(
                    (element) => element.label == widget.values[0].label)
                : Poll(),
            value: widget.polls[index],
            onChanged: (val) {},
            title: Text(polls[index].label ?? ""),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }));
  }
}
