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
  GdriveLinkListPin(
      {Key? key,
      required this.questId,
      this.questionResult,
      required this.edit,
      required this.Index})
      : super(key: key);
  final Answers? questionResult;
  final String questId;
  final int Index;
  bool edit = false;

  @override
  State<GdriveLinkListPin> createState() => _GdriveLinkListPinState();
}

class _GdriveLinkListPinState extends State<GdriveLinkListPin> {
  @override
  Widget build(BuildContext context) {
    var gDriveLinks = widget.questionResult != null
        ? widget.questionResult!.gDriveLink != null
            ? widget.questionResult!.gDriveLink
            : ''
        : '';

    var gDriveLinkList = gDriveLinks == '' ? [] : gDriveLinks!.split(',');

    void removeLink(item) {
      gDriveLinkList.removeWhere((element) => element == item);
      widget.questionResult!.gDriveLink = gDriveLinkList.join(',');
    }

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
        child: Column(
            children: gDriveLinkList
                .map<Widget>((e) => ListTile(
                      onTap: () {},
                      title: GestureDetector(
                        onTap: () async {},
                        child: InkWell(
                          onTap: () => launchUrl(Uri.parse(e)),
                          child: Text(
                            e.split("/").last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      trailing: Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.edit)
                                IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        removeLink(e);
                                        Provider.of<AnswerController>(context,
                                                listen: false)
                                            .removeFileAnswer(
                                                idFile: e.split("/").last,
                                                index: widget.Index,
                                                questId: widget.questId);

                                        print(gDriveLinkList);
                                      });
                                    }),
                            ],
                          )),
                    ))
                .toList()));
  }
}
