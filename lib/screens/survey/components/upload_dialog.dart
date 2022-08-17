import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:survey/screens/survey/controllers/file_upload.dart';
import 'package:survey/screens/survey/models/model_file.dart';
import 'package:survey/utils/extentions/ex.dart';

import '../../../data_sources/api/api_client.dart';
import '../controllers/answer_controller.dart';

class UploadDialog extends StatelessWidget {
  final List<ModelFile> files;
  final Function(List<ModelFile>) onUpload;

  const UploadDialog({
    Key? key,
    required this.files,
    required this.onUpload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ModelFile> listModelFile = filterList2(
        context.watch<FileUploadController>().listModelFile,
        context.read<ChooseFileController>().files);
    double height = 200 + 60 * listModelFile.length.toDouble();
    var loading = false;
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: Dialog(
        backgroundColor: Theme.of(context).backgroundColor,
        child: Container(
          height: height,
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Stack(
              children: [
                Column(
                  children: [
                    Text(
                      S.current.upload_file,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Divider(),
                    SizedBox(
                      height: padding,
                    ),
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: listModelFile
                            .map<Widget>((e) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.file!.path.split("/").last,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                    SizedBox(
                                      height: padding / 2,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            backgroundColor:
                                                Colors.blue.shade50,
                                            valueColor: e.progress != 1
                                                ? AlwaysStoppedAnimation<Color>(
                                                    Colors.blue)
                                                // : e.id.isEmpty
                                                //     ? AlwaysStoppedAnimation<
                                                //         Color>(Colors.red)
                                                : AlwaysStoppedAnimation<Color>(
                                                    Colors.green),
                                            value: e.progress,
                                          ),
                                        ),
                                        e.progress != 1
                                            ? IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: () async {
                                                  await Provider.of<
                                                              FileUploadController>(
                                                          context,
                                                          listen: false)
                                                      .closeUpload(e.file!);
                                                  if (context
                                                          .watch<
                                                              FileUploadController>()
                                                          .listModelFile
                                                          .length ==
                                                      0) {
                                                    Provider.of<ChooseFileController>(
                                                            context,
                                                            listen: false)
                                                        .offUploadFile();
                                                  }
                                                })
                                            :
                                            // e.id.isEmpty
                                            //     ? IconButton(
                                            //         icon: Icon(
                                            //           Icons.replay_outlined,
                                            //           color: Colors.red,
                                            //         ),
                                            //         onPressed: () async {
                                            //           await Provider.of<
                                            //                       FileUploadController>(
                                            //                   context,
                                            //                   listen: false)
                                            //               .uploadFile(
                                            //                   context, e.file!);
                                            //         })
                                            //
                                            //:
                                            IconButton(
                                                icon: Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.green,
                                                ),
                                                onPressed: null)
                                      ],
                                    ),
                                    if (e.progress! > 0 && e.progress! < 1)
                                      Text("Tài liệu đang tải lên ... ",
                                          style: TextStyle(color: Colors.red))
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      height: padding,
                    ),
                    ElevatedButton(
                        onPressed: listModelFile
                                .any((element) => element.progress != 0)
                            ? null
                            : () async {
                                loading = true;
                                // try {
                                // onUpload(listModelFile);
                                // context.read<FileUploadController>().;
                                // var uploadGoogle = () async {
                                //   var fileUpload = await ApiClient.signInGoogle(
                                //       listModelFile[0].file);

                                //   await Provider.of<AnswerController>(context,
                                //           listen: false)
                                //       .addFileAnswer(
                                //           idFile: fileUpload.id,
                                //           name: fileUpload.name,
                                //           index: listModelFile[0].index);
                                // };

                                onUpload(listModelFile);
                                // var fileUpload = await ApiClient.signInGoogle(
                                //     listModelFile[0].file);

                                // await Provider.of<AnswerController>(context,
                                //         listen: false)
                                //     .addFileAnswer(
                                //         idFile: fileUpload.id,
                                //         name: fileUpload.name,
                                //         index: listModelFile[0].index);

                                loading = false;
                                // listModelFile[0].id = fileUpload.id;

                                // } catch (e) {
                                //   print(e);
                                //   loading = false;
                                //   await showDialog(
                                //     context: context,
                                //     builder: (ctx) => AlertDialog(
                                //       title: Text('Có lỗi khi tải file'),
                                //       content: Text('không tải lên file được.'),
                                //       actions: <Widget>[
                                //         TextButton(
                                //           child: Text('Okay'),
                                //           onPressed: () {
                                //             Navigator.of(ctx).pop();
                                //           },
                                //         )
                                //       ],
                                //     ),
                                //   );
                                // }
                              },
                        child: Text(S.current.upload_file))
                  ],
                ),
                Positioned(
                    right: 0,
                    top: -10,
                    child: IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () async {
                          if (listModelFile
                              .every((element) => element.progress == 0)) {
                            for (int i = 0; i < listModelFile.length; i++) {
                              await Provider.of<FileUploadController>(context,
                                      listen: false)
                                  .closeUpload(listModelFile[i].file!);
                            }
                          }
                          Provider.of<ChooseFileController>(context,
                                  listen: false)
                              .offUploadFile();
                        }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
