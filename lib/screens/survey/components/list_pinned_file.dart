import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:provider/provider.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:survey/screens/survey/controllers/file_upload.dart';
import 'package:survey/screens/survey/models/model_answer.dart';
import 'package:survey/screens/survey/models/model_file.dart';
import 'package:survey/screens/survey/show_file.dart';
import 'package:survey/utils/extentions/ex.dart';

class ListPinnedFile extends StatefulWidget {
  const ListPinnedFile({
    Key? key,
    required this.questionIndex,
    required this.questId,
  }) : super(key: key);

  final int questionIndex;
  final String questId;
  @override
  State<ListPinnedFile> createState() => ListPinnedFileState();
}

class ListPinnedFileState extends State<ListPinnedFile> {
  var uploadError = false;

  void updateState() {
    setState(() {
      uploadError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ModelFile> listModelFile = filterList(
        context.watch<FileUploadController>().listModelFile,
        widget.questionIndex);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
      child: Column(
        children: listModelFile
            .map<Widget>(
              (e) => ListTile(
                onTap: () {
                  Provider.of<ChooseFileController>(context, listen: false)
                      .showUploadFile(widget.questionIndex);
                },
                title: Text(
                  e.file!.path.split("/").last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: LinearProgressIndicator(
                  backgroundColor: Colors.blue.shade50,
                  valueColor: e.failUpload
                      ? AlwaysStoppedAnimation<Color>(Colors.red)
                      : e.progress != 1
                          ? AlwaysStoppedAnimation<Color>(Colors.blue)
                          : AlwaysStoppedAnimation<Color>(Colors.green),
                  value: e.progress,
                ),
                trailing: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!e.file!.path.isFile())
                        IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ShowFile(file: e.file!)));
                            }),
                      IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            await Provider.of<FileUploadController>(context,
                                    listen: false)
                                .closeUpload(e.file!);
                            Provider.of<AnswerController>(context,
                                    listen: false)
                                .removeFileAnswer(
                                    idFile: e.id,
                                    index: widget.questionIndex,
                                    questId: widget.questId);
                          }),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ListPinnedFileComplete extends StatelessWidget {
  const ListPinnedFileComplete({
    Key? key,
    required this.medias,
  }) : super(key: key);
  final List<Media> medias;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: padding / 2,
        ),
        if (medias.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Text("Media"),
          ),
        ...medias
            .map<Widget>(
              (e) => ListTile(
                title: Text(
                  e.name ?? "file",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // trailing: Container(
                //   width: 100,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       IconButton(
                //           icon: Icon(Icons.visibility), onPressed: () {}),
                //     ],
                //   ),
                // ),
              ),
            )
            .toList(),
      ]),
    );
  }
}
