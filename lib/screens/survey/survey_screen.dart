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
import 'package:survey/screens/survey/components/select_file_dialog.dart';
import 'package:survey/screens/survey/components/upload_dialog.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:survey/screens/survey/controllers/file_upload.dart';

import 'components/item_survey.dart';
import 'models/model_file.dart';

class SurveyScreen extends StatelessWidget {
  final List<Questions> questions;
  final String campaignId;
  final String scheduleId;
  final bool isCompleted;
  final List<QuestionResultScheduleIdDto> questionResultScheduleIdDto;
  SurveyScreen({
    Key? key,
    required this.questions,
    required this.campaignId,
    required this.scheduleId,
    required this.questionResultScheduleIdDto,
    this.isCompleted = false,
  }) : super(key: key);
  final ScrollController scrollController = ScrollController();
  final List<GlobalKey> listKey = [];
  @override
  Widget build(BuildContext context) {
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
      data
      {
        _id
        question_result
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChooseFileController>(
            create: (_) => ChooseFileController()),
        ChangeNotifierProvider<FileUploadController>(
            create: (_) => FileUploadController(questionResultScheduleIdDto)),
        ChangeNotifierProvider<AnswerController>(
            create: (_) => AnswerController(
                campaignId: campaignId,
                scheduleId: scheduleId,
                listQuestions: questions,
                refQuestionResultScheduleIdDto: questionResultScheduleIdDto))
      ],
      builder: (context, child) => GraphQLProvider(
        client: client,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(
                  isCompleted ? "Kết quả khảo sát" : S.current.survey,
                  style: Theme.of(context).textTheme.headline6,
                ),
                actions: [
                  if (isCompleted)
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
                                        questions: questions,
                                        campaignId: campaignId,
                                        scheduleId: scheduleId,
                                        isCompleted: false,
                                        questionResultScheduleIdDto:
                                            questionResultScheduleIdDto,
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
                    child: questions.length > 0
                        ? SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            controller: scrollController,
                            child: Padding(
                                padding: EdgeInsets.only(bottom: padding * 4),
                                child: Column(
                                  children:
                                      List.generate(questions.length, (index) {
                                    listKey.add(GlobalKey());
                                    var question = questions[index];
                                    var questionResult =
                                        questionResultScheduleIdDto.length > 0
                                            ? questionResultScheduleIdDto
                                                .firstWhere((element) =>
                                                    element.question?.questID ==
                                                    question.questID)
                                            : null;
                                    int questionIndex = questions.length > 0
                                        ? questions.indexWhere((element) =>
                                            element.questID == question.questID)
                                        : -1;
                                    return ItemSurvey(
                                      key: listKey[index],
                                      question: question,
                                      isCompleted: isCompleted,
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
                  if (showBtn && questions.length > 0 && !isCompleted)
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
                                                          "value": scheduleId
                                                        }
                                                      ]
                                                    }
                                                  }
                                                }),
                                            builder: (result,
                                                {fetchMore, refetch}) {
                                              if (result.isLoading) {
                                                return Scaffold(
                                                  body: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              } else {
                                                ResponseListTemplate
                                                    responseListTemplate =
                                                    ResponseListTemplate
                                                        .fromJson(result.data!);
                                                var questionResult =
                                                    responseListTemplate
                                                        .querySchedulesDto!
                                                        .data![0]
                                                        .questionResultScheduleIdDto;
                                                return SurveyScreen(
                                                    questions: questions,
                                                    campaignId: campaignId,
                                                    scheduleId: scheduleId,
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
                                print(context
                                    .read<AnswerController>()
                                    .answer
                                    .toJson());
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
                !isCompleted)
              SelectFileDialog(),
            if (context.watch<ChooseFileController>().isUploadFile &&
                !isCompleted)
              UploadDialog(
                files: context.read<FileUploadController>().listModelFile,
                onUpload: (listModelFile) {
                  onUpload(context, listModelFile);
                },
              )
          ],
        ),
      ),
    );
  }

  onUpload(BuildContext context, List<ModelFile> listModelFile) async {
    for (int i = 0; i < listModelFile.length; i++) {
      await Provider.of<FileUploadController>(context, listen: false)
          .uploadFile(context, listModelFile[i].file!);
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
