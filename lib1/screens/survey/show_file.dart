import 'dart:io';

import 'package:flutter/material.dart';
import 'package:survey/screens/survey/controllers/choose_file_controller.dart';
import 'package:video_player/video_player.dart';

class ShowFile extends StatefulWidget {
  final File file;

  const ShowFile({Key? key, required this.file}) : super(key: key);

  @override
  _ShowFileState createState() => _ShowFileState();
}

class _ShowFileState extends State<ShowFile> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((value) => setState(() {}))
      ..play();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: widget.file.path.isImage()
            ? Image.file(widget.file)
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
      ),
    );
  }
}
