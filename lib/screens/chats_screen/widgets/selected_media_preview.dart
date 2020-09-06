import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:whatsapp_clone/widgets/video_player.dart';

import '../../../consts.dart';

class SelectedMediaPreview extends StatelessWidget {
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



  void send(String content) {
    onSend(
      content,
      type: MessageType.Media,
      mediaType: pickedMediaType,
      replyDetails: null,
    );
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
                _SelectedMedia(mediaType: pickedMediaType, file: file),
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
                        onPressed: onClosed,
                      ),
                    ),
                    Spacer(),
                    _TextField(
                      controller: textEditingController,
                      onSend: send,
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

class _SelectedMedia extends StatelessWidget {
  final MediaType mediaType;
  final File file;  
  const _SelectedMedia({
    Key key,
    @required this.mediaType,
    @required this.file,    
  }) : super(key: key);
 

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: size.height,     
      width: double.infinity,
      child: mediaType == MediaType.Photo
          ? Image.file(
              file,
              fit: BoxFit.cover,
              height: size.height,              
              width: double.infinity,
            )
          : CVideoPlayer(video: file, isLocal: true),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final Function onSend;
  const _TextField({
    Key key,
    @required this.controller,
    @required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      width: size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: _InputField(controller: controller, onSend: onSend),
          ),
          SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: kBlackColor3.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),              
            ),
            alignment: Alignment.center,
            child: CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: Icon(Icons.send,
                  size: 30, color: Theme.of(context).accentColor),
              onPressed: () => onSend(controller.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    Key key,
    @required this.controller,
    @required this.onSend,
  }) : super(key: key);

  final TextEditingController controller;
  final Function onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              maxLines: null,
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.95)),
              controller: controller,
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
              onSubmitted: onSend,
            ),
          ),          
        ],
      ),
    );
  }
}
