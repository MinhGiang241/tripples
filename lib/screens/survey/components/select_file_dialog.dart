import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';

import 'item_survey.dart';

class SelectFileDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: Dialog(
        backgroundColor: Theme.of(context).backgroundColor,
        child: Container(
          height: 200,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Stack(
              children: [
                Column(
                  //mainAxisAlignment: MainAxisAlignment.s,
                  children: [
                    Text(
                      S.current.select_file,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Divider(),
                    SizedBox(
                      height: padding,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SelectFileButton(
                            iconData: Icons.perm_media_rounded,
                            color: Colors.blue,
                            onPressed: () {
                              Provider.of<ChooseFileController>(context,
                                      listen: false)
                                  .chooseMediaFile(context);
                            },
                            title: S.current.image_video,
                          ),
                          SelectFileButton(
                            iconData: Icons.file_copy,
                            color: Colors.orange,
                            onPressed: () {
                              Provider.of<ChooseFileController>(context,
                                      listen: false)
                                  .chooseFileCustom(context);
                            },
                            title: S.current.file,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                    right: 0,
                    top: -10,
                    child: IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () {
                          Provider.of<ChooseFileController>(context,
                                  listen: false)
                              .offSelectFile();
                        }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
