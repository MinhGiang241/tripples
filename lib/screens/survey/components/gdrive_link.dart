import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:googleapis/chat/v1.dart';
import 'package:provider/provider.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';
import '../../../models/response_list_campaign.dart';
import '../controllers/file_upload.dart';
import '../models/model_file.dart';

class GdriveLinkListPin extends StatefulWidget {
  const GdriveLinkListPin(
      {Key? key,
      required this.questId,
      this.questionResult,
      required this.Index})
      : super(key: key);
  final Answers? questionResult;
  final String questId;
  final int Index;
  @override
  State<GdriveLinkListPin> createState() => _GdriveLinkListPinState();
}

class _GdriveLinkListPinState extends State<GdriveLinkListPin> {
  @override
  Widget build(BuildContext context) {
    var gDriveLink = Provider.of<AnswerController>(context, listen: false)
        .listResult
        .firstWhere((e) => e.questionTemplateId == widget.questId)
        .google_drive_ids;
    var listGdriveLink;
    if (gDriveLink != null && gDriveLink != '') {
      listGdriveLink = gDriveLink.split(',');
    }

    // if (widget.questionResult != null &&
    //     widget.questionResult!.gDriveLink != '' &&
    //     widget.questionResult!.gDriveLink != null) {
    //   gDriveLink = widget.questionResult!.gDriveLink!.split(',');
    // }
    // var modelFiles = [];
    // gDriveLink.asMap().forEach((i, v) {
    //   modelFiles.add(ModelFile(index: i, name: v.split(',').last));
    // });
    // Provider.of<FileUploadController>(context, listen: false).addFile(
    //   gDriveLink.asMap().map((i,v)=> new ModelFile())
    //   );
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
        child: Column(
            children: listGdriveLink == null
                ? []
                : listGdriveLink
                    .map<Widget>((e) => ListTile(
                          onTap: () {},
                          title: GestureDetector(
                            onTap: () async {
                              // print(e);
                              // if (await canLaunch(e)) {
                              //   launchUrl(Uri.parse(e));
                              // }

                              // if (await canLaunch(e)) launch(e);
                            },
                            child: Text(
                              e.split("/").last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: Container(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () async {
                                        setState(() {
                                          // gDriveLink.removeWhere(
                                          //     (element) => element == e);
                                          // print(gDriveLink);
                                        });
                                        await Provider.of<AnswerController>(
                                                context,
                                                listen: false)
                                            .removeFileAnswer(
                                                idFile: e.split("/").last,
                                                index: widget.Index,
                                                questId: widget.questId);
                                        print(listGdriveLink);
                                      }),
                                ],
                              )),
                        ))
                    .toList()));
  }
}
