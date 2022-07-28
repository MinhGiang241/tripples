import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/models/campaign.dart';
import 'package:survey/models/department.dart';
import 'package:survey/screens/auth/components/auth_button.dart';
import 'package:survey/screens/survey/survey_screen.dart';
import 'package:provider/provider.dart';
import 'components/list_details.dart';

import 'package:survey/models/response_list_campaign.dart';

class DetailsScreen extends StatelessWidget {
  final String idCampaign;
  final RefDepartmentIdDepartmentDto department;
  final bool isCompleted;
  final String idSchedule;
  final List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  const DetailsScreen({
    Key? key,
    required this.idCampaign,
    required this.department,
    required this.isCompleted,
    required this.idSchedule,
    this.questionResultScheduleIdDto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(" id campain: " + idCampaign);
    final String detailsQuery = """
  query {
    find_Campaign_dto(_id : "$idCampaign"){
      data{
        _id
        name
        description
        end_time
        createdTime
        isLocked
        isOpen
        schema
        start_time
        updatedTime
        
      }
      message
    }
  }
  """;
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
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.current.details,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: SafeArea(
            child: idCampaign.isEmpty
                ? Center(
                    child: Text("Không có dữ liệu"),
                  )
                : Query(
                    options: QueryOptions(
                      document: gql(detailsQuery),
                    ),
                    builder: (result, {fetchMore, refetch}) {
                      if (result.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (result.hasException) {
                        return Center(
                          child: Text(result.exception.toString()),
                        );
                      }
                      if (result.data!["find_Campaign_dto"]["data"] == null) {
                        return Center(
                          child: Text("Không có dữ liệu"),
                        );
                      }
                      RefCampaignIdCampaignDto refCampaignIdCampaignDto =
                          RefCampaignIdCampaignDto.fromJson(
                              result.data!["find_Campaign_dto"]["data"] ?? {});

                      return Stack(
                        children: [
                          ListDetails(
                            refCampaignIdCampaignDto: refCampaignIdCampaignDto,
                            department: department,
                          ),
                          Positioned(
                            bottom: padding,
                            left: MediaQuery.of(context).size.width / 4,
                            right: MediaQuery.of(context).size.width / 4,
                            child: AuthButton(
                              onPress: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => SurveyScreen(
                                              campaignId: idCampaign,
                                              scheduleId: idSchedule,
                                              isCompleted: isCompleted,
                                              questions:
                                                  refCampaignIdCampaignDto
                                                          .questions ??
                                                      [],
                                              questionResultScheduleIdDto:
                                                  questionResultScheduleIdDto ??
                                                      [],
                                            )));
                              },
                              title: isCompleted
                                  ? S.current.result
                                  : S.current.start,
                            ),
                          )
                        ],
                      );
                    },
                  )),
      ),
    );
  }
}
