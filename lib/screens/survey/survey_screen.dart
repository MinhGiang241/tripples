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
import 'package:survey/screens/survey/components/list_pinned_file.dart';
import 'package:survey/screens/survey/components/select_file_dialog.dart';
import 'package:survey/screens/survey/components/upload_dialog.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:survey/screens/survey/controllers/file_upload.dart';

import '../../data_sources/api/api_client.dart';
import '../../models/campaign.dart';
import 'components/item_survey.dart';
import 'models/model_file.dart';

class SurveyScreen extends StatefulWidget {
  final List<Questions>? questions;
  final String campaignId;
  final String scheduleId;
  final bool isCompleted;
  final List<QuestionResultScheduleIdDto> questionResultScheduleIdDto;
  final RefCampaignIdCampaignDto? campaign;
  SurveyScreen(
      {Key? key,
      this.questions,
      required this.campaignId,
      required this.scheduleId,
      required this.questionResultScheduleIdDto,
      this.isCompleted = false,
      this.campaign})
      : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final ScrollController scrollController = ScrollController();

  final List<GlobalKey> listKey = [];

  final GlobalKey<UploadDialogState> DialogState =
      GlobalKey<UploadDialogState>();

  @override
  Widget build(BuildContext context) {
    print(widget.questions);
    final mutationData = """
  mutation (\$campaign_id:String, \$schedule_id: String,  \$resultsList :  Dictionary){ 
	question_result_save(campaignId : \$campaign_id, , scheduleId: \$schedule_id, resultsList: \$resultsList){
    message
    code
    data
  }
} 
    """;

    final String queryTemplate = """
 query(\$filter:GeneralCollectionFilterInput)
  {
    query_Schedules_dto(filter:\$filter)
    {
      code
      message
      data
      {
        _id 
        appointment_date
        appointment_time
        ref_tenantId_CompanyDto{
          _id
          name
        }
        ref_campaignId_CampaignDto{
          _id
          name
          start_time
          end_time
        }
        ref_departmentId_DepartmentDto{
          name
          address
        }
        ref_QuestionResult_scheduleIdDto {
          campaignId
          departmentId
          creator
          departmentId
          display_name
          follower_numb
          media
          updatedTime
          note
          score
          task_numb
          tenantId
          values {
            factor
            label
          }
          question {
            name
            max_score
            poll {
              factor
              icon
              label
            }
            questID
            type
          }
        }
      }
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
        cache: GraphQLCache(store: HiveStore()),
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
                listQuestions: [], //widget.questions,
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
                                              style:
                                                  TextStyle(color: Colors.grey),
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
                                        questions: widget.questions,
                                        campaignId: widget.campaignId,
                                        scheduleId: widget.scheduleId,
                                        isCompleted: false,
                                        questionResultScheduleIdDto:
                                            widget.questionResultScheduleIdDto,
                                      ),
                                    ),
                                  );
                                }
                              }
                            });
                          },
                          icon: Icon(
                            Icons.edit_rounded,
                            size: 18,
                          ),
                          label: Text("Edit   ")),
                    )
                ],
              ),
              body: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: widget.questions != null &&
                            widget.questions!.length > 0
                        ? SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            controller: scrollController,
                            child: Padding(
                                padding: EdgeInsets.only(bottom: padding * 4),
                                child: Column(
                                  children: List.generate(
                                      widget.questions!.length, (index) {
                                    listKey.add(GlobalKey());
                                    var question = widget.questions![index];
                                    var questionResult = widget
                                                .questionResultScheduleIdDto
                                                .length >
                                            0
                                        ? widget.questionResultScheduleIdDto
                                            .firstWhere((element) =>
                                                element.question?.questID ==
                                                question.questID)
                                        : null;
                                    int questionIndex =
                                        widget.questions!.length > 0
                                            ? widget
                                                .questions!
                                                .indexWhere((element) =>
                                                    element.questID ==
                                                    question.questID)
                                            : -1;
                                    return ItemSurvey(
                                      key: listKey[index],
                                      question: question,
                                      isCompleted: widget.isCompleted,
                                      questID: question.questID ?? "",
                                      questionResultScheduleIdDto:
                                          questionResult,
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
                      widget.questions != null &&
                      widget.questions!.length > 0 &&
                      !widget.isCompleted)
                    Mutation(
                      options: MutationOptions(
                          document: gql(mutationData),
                          onCompleted: (data) async {
                            await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Thông báo"),
                                content: Text(
                                    data!["question_result_save"]["code"] == 0
                                        ? "Thành công"
                                        : "Thất bại"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        if (data["question_result_save"]
                                                ["code"] !=
                                            0) {
                                          Navigator.pop(context);
                                        } else {
                                          Navigator.pop(context, true);
                                        }
                                      },
                                      child: Text("OK"))
                                ],
                              ),
                            ).then((value) {
                              if (value != null) {
                                if (value == true) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GraphQLProvider(
                                          client: client,
                                          child: Query(
                                            options: QueryOptions(
                                                document: gql(queryTemplate),
                                                variables: {
                                                  "filter": {
                                                    "withRecords": true,
                                                    "group": {
                                                      "children": [
                                                        {
                                                          "id": "_id",
                                                          "value":
                                                              widget.scheduleId
                                                        }
                                                      ]
                                                    }
                                                  }
                                                }),
                                            builder: (result,
                                                {fetchMore, refetch}) {
                                              if (result.isLoading) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              } else {
                                                ResponseListTemplate
                                                    responseListTemplate =
                                                    ResponseListTemplate
                                                        .fromJson(result.data!);
                                                if (result.data![
                                                            "query_Schedules_dto"]
                                                        ['code'] !=
                                                    0) {
                                                  // setState() {
                                                  //   ScaffoldMessenger.of(
                                                  //           context)
                                                  //       .showSnackBar(SnackBar(
                                                  //     content: const Text(
                                                  //         'Không gửi được kết quả'),
                                                  //     duration: const Duration(
                                                  //         seconds: 1),
                                                  //     action: SnackBarAction(
                                                  //       label: 'Lỗi',
                                                  //       onPressed: () {},
                                                  //     ),
                                                  //   ));
                                                  // }

                                                  Navigator.pop(context, true);
                                                  return Center(
                                                      child: Text(''));
                                                }
                                                var questionResult =
                                                    responseListTemplate
                                                        .querySchedulesDto!
                                                        .data![0]
                                                        .questionResultScheduleIdDto;
                                                print(questionResult);
                                                return SurveyScreen(
                                                    questions: widget.questions,
                                                    campaignId:
                                                        widget.campaignId,
                                                    scheduleId:
                                                        widget.scheduleId,
                                                    isCompleted: true,
                                                    questionResultScheduleIdDto:
                                                        responseListTemplate
                                                                    .querySchedulesDto!
                                                                    .data![0]
                                                                    .questionResultScheduleIdDto !=
                                                                null
                                                            ? questionResult ??
                                                                []
                                                            : []);
                                              }
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
                            onPress: () {
                              bool valid = Provider.of<AnswerController>(
                                      context,
                                      listen: false)
                                  .valid();
                              if (valid) {
                                var ans = context
                                    .read<AnswerController>()
                                    .answer
                                    .toJson();
                                print(ans);
                                // return;
                                runMutation(context
                                    .read<AnswerController>()
                                    .answer
                                    .toJson());
                              } else {
                                scrollToRequired(context);
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
                            index: listModelFile[0].index);
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

  onUpload(BuildContext context, List<ModelFile> listModelFile,
      Function uploadGoogle, Function stopUpload) {
    for (int i = 0; i < listModelFile.length; i++) {
      Provider.of<FileUploadController>(context, listen: false).uploadFile(
          context, listModelFile[i].file!, uploadGoogle, stopUpload);
    }
  }

  scrollToRequired(BuildContext context) {
    int index = 0;
    for (var i = 0;
        i < context.read<AnswerController>().answer.resultsList!.length;
        i++) {
      if (context
          .read<AnswerController>()
          .answer
          .resultsList![i]
          .values!
          .isEmpty) {
        index = i;
        break;
      }
    }
    RenderBox box =
        listKey[index].currentContext!.findRenderObject() as RenderBox;
    double offset = box.localToGlobal(Offset.zero).dy;
    scrollController.animateTo(offset,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }
}
