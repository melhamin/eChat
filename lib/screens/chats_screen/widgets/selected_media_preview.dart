import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:whatsapp_clone/widgets/video_player.dart';

import '../../../consts.dart';

class SelectedMediaPreview extends StatefulWidget {
  final File file;
  final TextEditingController textEditingController;
  final Function onSend;
  final Function onClosed;
  final MediaType pickedMediaType;
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
  Widget _buildPhoto() {
    return Image.file(widget.file, fit: BoxFit.cover);
  }

  void send(String content) {
    print('media preview ===---> msg type =====> ${widget.pickedMediaType}');
    widget.onSend(content,
        type: MessageType.Media,
        mediaType: widget.pickedMediaType,
        replyDetails: null);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(
          maxHeight: mq.size.height,
        ),
        color: kBlackColor2,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: mq.size.height,
                  constraints: BoxConstraints(
                    // maxHeight: constraints.maxHeight,
                  ),
                  width: double.infinity,
                  child: widget.pickedMediaType == MediaType.Photo
                      ? Image.file(
                          widget.file,
                          fit: BoxFit.cover,
                          height: constraints.maxHeight,
                          width: double.infinity,
                        )
                      : CVideoPlayer(video: widget.file, isLocal: true),
                ),
                Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kBlackColor3.withOpacity(0.7),                       
                      ),
                      child: Icon(Icons.close,
                          color: Theme.of(context).accentColor, size: 20),
                    ),
                    onPressed: widget.onClosed,
                  ),
                ),
                
                Spacer(),
                Container(
                  margin:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: kBlackColor3.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    // border: Border.all(color: kBorderColor3)
                  ),
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
                          onSubmitted: (value) => send(value),
                        ),
                      ),
                      // Spacer(),
                      CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          child: Icon(Icons.send,
                              size: 30, color: Theme.of(context).accentColor),
                          onPressed: () =>
                              send(widget.textEditingController.text)),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
              ],
            );
          },
        ),
      ),
    );
  }
}
