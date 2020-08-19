import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../consts.dart';

class SelectedMediaPreview extends StatefulWidget {
  final File file;
  final TextEditingController textEditingController;
  final Function onSend;
  final Function onClosed;
  final PickedMediaType pickedMediaType;
  SelectedMediaPreview({
    @required this.file,
    @required this.textEditingController,
    @required this.onSend,
    @required this.onClosed,
    @required this.pickedMediaType,
  });

  @override
  _SelectedMediaPreviewState createState() => _SelectedMediaPreviewState();
}

class _SelectedMediaPreviewState extends State<SelectedMediaPreview> {
  VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();
  _videoPlayerController = VideoPlayerController.file(widget.file)
      ..initialize().then((_) => setState(() {_videoPlayerController.play();}));
  }

  Widget _buildVideo() {
    return _videoPlayerController.value.initialized ?
    AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: VideoPlayer(_videoPlayerController, ),
    ) : Container();
  }

  Widget _buildPhoto() {
    return Image.file(widget.file, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
        body: Container(
      constraints: BoxConstraints(
        maxHeight: mq.size.height,
      ),
      color: kBlackColor,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                    child: Icon(Icons.close, color: kBaseWhiteColor, size: 25),
                    onPressed: widget.onClosed),
              ),
              Container(
                alignment: Alignment.center,
                height: constraints.maxHeight * 0.8 - 35,
                width: double.infinity,
                child: widget.pickedMediaType == PickedMediaType.Photo
                    ? _buildPhoto()
                    : _buildVideo(),
              ),
              Spacer(),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                decoration: BoxDecoration(
                    color: kBlackColor3,
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 5),
                    Flexible(
                      child: TextField(
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.95)),
                        controller: widget.textEditingController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        cursorColor: Theme.of(context).accentColor,
                        keyboardAppearance: Brightness.dark,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          border: InputBorder.none,
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        onSubmitted: (value) {
                          widget.onSend(value, type: MessageType.Media, mediaType: widget.pickedMediaType);
                          // Navigator.of(context).pop();
                        },
                      ),
                    ),
                    // Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      child: Icon(Icons.send,
                          size: 30, color: Theme.of(context).accentColor),
                      onPressed: () =>
                          widget.onSend(widget.textEditingController.text, type: MessageType.Media, mediaType: widget.pickedMediaType),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}
