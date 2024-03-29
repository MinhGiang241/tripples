import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/auth/components/auth_button.dart';
import 'package:survey/screens/root/root_screen.dart';
import 'package:survey/screens/survey/components/select_file_dialog.dart';
import 'package:survey/screens/survey/components/upload_dialog.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:survey/screens/survey/controllers/file_upload.dart';
import 'package:intl/intl.dart';
import 'package:survey/utils/extentions/ex.dart';
import 'package:diacritic/diacritic.dart';

import '../../data_sources/api/api_client.dart';
import '../../models/campaign.dart';
import 'components/item_survey.dart';
import 'models/model_file.dart';

class SurveyScreen extends StatefulWidget {
  final List<Questions> questions;
  final String campaignId;
  final String scheduleId;
  final bool isCompleted;
  final String status;
  final List<QuestionResultScheduleIdDto> questionResultScheduleIdDto;
  final QuestionResult questionResults;
  final RefCampaignIdCampaignDto? campaign;
  SurveyScreen(
      {Key? key,
      required this.questions,
      required this.campaignId,
      required this.scheduleId,
      required this.questionResultScheduleIdDto,
      required this.questionResults,
      this.status = '',
      this.isCompleted = false,
      this.campaign})
      : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final ScrollController scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final List<GlobalKey> listKey = [];

  final GlobalKey<UploadDialogState> DialogState =
      GlobalKey<UploadDialogState>();
  bool disabled = false;
  @override
  Widget build(BuildContext context) {
    print(widget.questions);
    final mutationData = """
  mutation (\$data:Dictionary){
   scheduleresult_save_schedule_result (data: \$data ) {
        code
        message
        data
    }
  }
    """;

    final String changeStatus = """
        mutation(\$scheduleId: String , \$newStatus: String){
      schedule_change_status_schedule(scheduleId: \$scheduleId ,newStatus: \$newStatus ){
        code
        message
        data
      }
    }
  """;
    final bool showBtn = MediaQuery.of(context).viewInsets.bottom == 0.0;
    final HttpLink httpLink = HttpLink(ApiConstants.baseUrl);

    final AuthLink authLink = AuthLink(
        getToken: () => 'Bearer ${context.read<AuthController>().token}');
    final Link link = authLink.concat(httpLink);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(
            // store: HiveStore()
            ),
      ),
    );

    var stopUpload = (File file) async {
      // Provider.of<ChooseFileController>(context, listen: false)
      //     .offUploadFile();
      // Provider.of<ChooseFileController>(context, listen: false)
      //     .removeFile(file);
      // Provider.of<FileUploadController>(context, listen: false)
      //     .closeUpload(file);

      // DialogState.currentState?.updateState();
    };

    getFormattedDateFromFormattedString(
        {required value,
        required String currentFormat,
        required String desiredFormat,
        isUtc = false}) {
      DateTime? dateTime = DateTime.now();
      if (value != null || value.isNotEmpty) {
        try {
          dateTime = DateFormat(currentFormat).parse(value, isUtc).toLocal();
        } catch (e) {
          print("$e");
        }
      }
      return dateTime;
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChooseFileController>(
            create: (_) => ChooseFileController()),
        ChangeNotifierProvider<FileUploadController>(
            create: (_) =>
                FileUploadController(widget.questionResultScheduleIdDto)),
        ChangeNotifierProvider<AnswerController>(
            create: (_) => AnswerController(
                campaignId: widget.campaignId,
                scheduleId: widget.scheduleId,
                listQuestions: widget.questions,
                questionResults: widget.questionResults, //widget.questions,
                refQuestionResultScheduleIdDto:
                    widget.questionResultScheduleIdDto))
      ],
      builder: (context, child) => GraphQLProvider(
        client: client,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.isCompleted ? "Kết quả khảo sát" : S.current.survey,
                  style: Theme.of(context).textTheme.headline6,
                ),
                actions: [
                  if (widget.isCompleted)
                    Padding(
                      padding: EdgeInsets.only(right: padding / 2),
                      child: TextButton.icon(
                          onPressed: () async {
                            // print(widget
                            //     .questionResults.answers?[0].updatedTime!);

                            DateTime? dateTime =
                                getFormattedDateFromFormattedString(
                                    value: widget.questionResults.answers?[0]
                                        .updatedTime!,
                                    currentFormat: "yyyy-MM-ddTHH:mm:ssZ",
                                    desiredFormat: "yyyy-MM-dd HH:mm:ss");

                            // print(dateTime!.year); //2021-12-15 11:10:01.000
                            // print(dateTime.month); //2021-12-15 11:10:01.000
                            // print(dateTime.day); //2021-12-15 11:10:01.000
                            if (DateTime.now().year == dateTime!.year &&
                                DateTime.now().month == dateTime.month &&
                                DateTime.now().day == dateTime.day) {
                              await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Thông báo"),
                                        content: Text(
                                            "Bạn có muốn chỉnh sửa phần trả lời khảo sát của mình ?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: Text(
                                                "Không",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: Text("Có")),
                                        ],
                                      )).then((value) {
                                if (value != null) {
                                  if (value == true) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SurveyScreen(
                                            status: widget.status,
                                            questions: widget.questions,
                                            campaignId: widget.campaignId,
                                            scheduleId: widget.scheduleId,
                                            isCompleted: false,
                                            questionResultScheduleIdDto: widget
                                                .questionResultScheduleIdDto,
                                            questionResults:
                                                widget.questionResults),
                                      ),
                                    );
                                  }
                                }
                              });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                          title: Text('Thông báo'),
                                          content: Text(
                                              'Lịch triển khai đã qua ngày không thể chỉnh sửa'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Đóng'))
                                          ]));
                            }
                          },
                          icon: Icon(
                            Icons.edit_rounded,
                            size: 18,
                          ),
                          label: Text("Sửa   ")),
                    )
                ],
              ),
              body: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: widget.questions.length > 0
                          ? SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              controller: scrollController,
                              child: Padding(
                                  padding: EdgeInsets.only(bottom: padding * 4),
                                  child: Column(
                                    children: List.generate(
                                        widget.questions.length, (index) {
                                      listKey.add(GlobalKey());
                                      // var listQuestion =
                                      widget.questions.sort((a, b) =>
                                          removeDiacritics(a.title as String)
                                              .compareTo(removeDiacritics(
                                                  b.title as String)));
                                      var question = widget.questions[index];
                                      var questionResult = widget
                                                  .questionResults.answers !=
                                              null
                                          ? widget.questionResults.answers!
                                                      .length >
                                                  0
                                              ? widget.questionResults.answers
                                                  ?.firstWhere((element) =>
                                                      element
                                                          .questionTemplateId ==
                                                      question.questID)
                                              : null
                                          : null;
                                      int questionIndex =
                                          widget.questions.length > 0
                                              ? widget.questions.indexWhere(
                                                  (element) =>
                                                      element.questID ==
                                                      question.questID)
                                              : -1;
                                      return ItemSurvey(
                                        formKey: _formKey,
                                        key: listKey[index],
                                        question: question,
                                        isCompleted: widget.isCompleted,
                                        questID: question.questID ?? "",
                                        questionResult: questionResult,
                                        questionIndex: questionIndex,
                                      );
                                    }),
                                  )),
                            )
                          : Center(
                              child: Text("Không có câu hỏi nào"),
                            ),
                    ),
                    if (showBtn &&
                        widget.questions.length > 0 &&
                        !widget.isCompleted)
                      Mutation(
                        options: MutationOptions(
                            document: gql(mutationData),
                            onCompleted: (data) async {
                              await showDialog(
                                context: context,
                                builder: (_) {
                                  if (data == null) {
                                    return AlertDialog(
                                        title: Text('Có lỗi xảy ra'),
                                        content: Text("Kiểm tra lại kết nối"),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Đóng'))
                                        ]);
                                  }
                                  if (data["scheduleresult_save_schedule_result"]
                                          ["code"] !=
                                      0) {
                                    return AlertDialog(
                                        title: Text('Có lỗi xảy ra'),
                                        content:
                                            Text("Không gửi kết quả lên được "),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Đóng'))
                                        ]);
                                  }
                                  return AlertDialog(
                                    title: data["scheduleresult_save_schedule_result"]
                                                    ["code"] ==
                                                0 &&
                                            data["scheduleresult_save_schedule_result"]
                                                    ["data"]["failure"] ==
                                                0
                                        ? Text("Thành công")
                                        : Text("Thất bại"),
                                    content: data["scheduleresult_save_schedule_result"]
                                                ["code"] ==
                                            0
                                        ? Text(
                                            data["scheduleresult_save_schedule_result"]
                                                    ["data"]["message"]
                                                .split('<')
                                                .first)
                                        : Text(data[
                                                "scheduleresult_save_schedule_result"]
                                            ["message"]),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            if (data["scheduleresult_save_schedule_result"]
                                                    ["code"] !=
                                                0) {
                                              Navigator.pop(context);
                                            } else {
                                              Navigator.pop(context, true);
                                            }
                                          },
                                          child: Text("OK"))
                                    ],
                                  );
                                },
                              ).then((value) {
                                if (value != null) {
                                  if (value == true) {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GraphQLProvider(
                                            client: client,
                                            child: Mutation(
                                              options: MutationOptions(
                                                  document: gql(changeStatus),
                                                  onCompleted: (result) {
                                                    disabled = false;
                                                    if (result == null) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Có lỗi xảy ra '),
                                                              content: Text(
                                                                  'xem lại kết nối internet'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      'Đóng'),
                                                                )
                                                              ],
                                                            );
                                                          });
                                                    } else if (result[
                                                                'schedule_change_status_schedule']
                                                            ['code'] !=
                                                        0) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Không chuyển trạng thái chiến dịch được'),
                                                              content: Text(
                                                                  result['schedule_change_status_schedule']
                                                                          [
                                                                          'message']
                                                                      .split(
                                                                          ':')
                                                                      .last),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      'Đóng'),
                                                                )
                                                              ],
                                                            );
                                                          });
                                                    } else {}
                                                  }),
                                              builder: (runMutation, result) {
                                                return RootScreen();
                                              },
                                            ),
                                          ),
                                        ),
                                        (route) => route.isFirst);
                                  }
                                }
                              });
                            }),
                        builder: (runMutation, result) {
                          return Positioned(
                            bottom: padding,
                            left: MediaQuery.of(context).size.width / 4,
                            right: MediaQuery.of(context).size.width / 4,
                            child: AuthButton(
                              disabled: disabled,
                              onPress: () {
                                setState(() {
                                  disabled = true;
                                });

                                var listResult =
                                    context.read<AnswerController>().listResult;
                                var data = [];
                                listResult.forEach((v) {
                                  data.add(v.toJson());
                                });
                                print(data);
                                try {
                                  validation(context, widget.questions);

                                  if (_formKey.currentState!.validate() &&
                                      validationForm(context)) {
                                    runMutation({"data": data});
                                  } else {
                                    disabled = false;
                                    showDialog(
                                        context: context,
                                        builder: (ctxt) => new AlertDialog(
                                              title: Text("Thông báo"),
                                              content: Text(
                                                  "Dữ liệu khảo sát không hợp lệ"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    child: Text("Đóng")),
                                              ],
                                            ));
                                  }
                                } catch (e) {
                                  disabled = false;
                                  showDialog(
                                      context: context,
                                      builder: (ctxt) => new AlertDialog(
                                            title: Text("Có lỗi xảy ra"),
                                            content:
                                                Text("Không gửi được kết quả"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, true);
                                                  },
                                                  child: Text("Đóng")),
                                            ],
                                          ));
                                }
                              },
                              title: S.current.send,
                            ),
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
            if (context.watch<ChooseFileController>().isSelectedFile &&
                !widget.isCompleted)
              SelectFileDialog(),
            if (context.watch<ChooseFileController>().isUploadFile &&
                !widget.isCompleted)
              UploadDialog(
                key: DialogState,
                files: context.read<FileUploadController>().listModelFile,
                // uploadError: uploadError,
                onUpload: (
                  listModelFile,
                ) {
                  var uploadGoogle = () async {
                    var fileUpload =
                        await ApiClient.signInGoogle(listModelFile[0].file);

                    await Provider.of<AnswerController>(context, listen: false)
                        .addFileAnswer(
                      idFile: fileUpload.id,
                      name: fileUpload.name,
                      index: listModelFile[0].index,
                      questID: listModelFile[0].questID,
                    );
                    Provider.of<ChooseFileController>(context, listen: false)
                        .offUploadFile();
                    print(Provider.of<AnswerController>(context, listen: false)
                        .listResult);
                    return fileUpload;
                  };
                  onUpload(context, listModelFile, uploadGoogle, stopUpload);
                },
              )
          ],
        ),
      ),
    );
  }

  void validation(BuildContext context, List<Questions> questions) {
    var listResult = context.read<AnswerController>().listResult;
    setState(() {
      for (var question in questions) {
        if (!question.required) {
          question.valid = true;
        }
        switch (question.type) {
          case "ONECHOOSE":
            if (listResult
                    .where((element) =>
                        element.questionTemplateId == question.questID &&
                        element.answerText != "")
                    .length <=
                0) {
              question.valid = false;
              // disabled = false;

              break;
            } else {
              question.valid = true;
              break;
            }

          case "MULTIPLECHOOSE":
            if (listResult
                    .where((element) =>
                        element.questionTemplateId == question.questID &&
                        element.answerText != "")
                    .length <=
                0) {
              question.valid = false;
              // disabled = false;
              break;
            } else {
              question.valid = true;
              break;
            }
          default:
            question.valid = true;
        }
      }
    });
  }

  bool validationForm(BuildContext context) {
    var listResult = context.read<AnswerController>().listResult;
    var valid = true;
    for (var e in widget.questions) {
      var result = listResult
          .firstWhere((element) => element.questionTemplateId == e.questID);
      if ((result.answerText == null || result.answerText == "") &&
          e.required &&
          (e.type == "TEXT" ||
              e.type == "ONECHOOSE" ||
              e.type == "MULTIPLECHOOSE")) {
        valid = false;
        e.valid = false;
        disabled = false;
        break;
      }
      if (result.answerNumber == null && e.required && e.type == "NUMBER") {
        valid = false;
        e.valid = false;
        break;
      }
      e.valid = true;
    }
    Future.delayed(Duration(seconds: 1));
    return valid;
  }

  onUpload(BuildContext context, List<ModelFile> listModelFile,
      Function uploadGoogle, Function stopUpload) {
    for (int i = 0; i < listModelFile.length; i++) {
      Provider.of<FileUploadController>(context, listen: false).uploadFile(
          context, listModelFile[i].file!, uploadGoogle, stopUpload);
    }
  }
}
