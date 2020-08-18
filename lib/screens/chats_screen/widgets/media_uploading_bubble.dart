import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/database/storage.dart';
import 'package:whatsapp_clone/models/message.dart';

class MediaUploadingBubble extends StatefulWidget {
  final String groupId;
  final File image;
  final DateTime time;
  final Function onUploadFinished;
  final Message message;
  MediaUploadingBubble({
    @required this.groupId,
    @required this.image,
    @required this.time,
    @required this.onUploadFinished,
    @required this.message,
  });
  @override
  _MediaUploadingBubbleState createState() => _MediaUploadingBubbleState();
}

class _MediaUploadingBubbleState extends State<MediaUploadingBubble> {
  Storage _storage;
  StorageUploadTask _uploadTask;

  bool uploadStarted = false;
  String path;
  var timestamp;

  @override
  void initState() {
    super.initState();
    _storage = Storage();
    setState(() {
      timestamp = widget.time.millisecondsSinceEpoch;
      path = 'ChatsMedia/${widget.groupId}/$timestamp.png';
      _uploadTask = _storage.getUploadTask(widget.image, path);
    });
  }

  void onUploadCompleted() async {
    var url =
        await _storage.getUrl('ChatsMedia/${widget.groupId}', '$timestamp');
    widget.onUploadFinished(url);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Hexcolor('#202020'),
        ),
        padding: const EdgeInsets.all(5),
        // height: mq.size.height * 0.35,
        width: mq.size.width * 0.7,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          alignment: WrapAlignment.end,
          runAlignment: WrapAlignment.spaceBetween,
          children: [
            Wrap(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: mq.size.height * 0.35,
                          maxWidth: mq.size.width * 0.7,
                        ),
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.file(widget.image, fit: BoxFit.cover),
                      ),
                    ),
                    StreamBuilder<StorageTaskEvent>(
                      stream: _uploadTask.events,
                      builder: (ctx, snapshots) {
                        if (_uploadTask.isComplete &&
                            _uploadTask.isSuccessful) {
                          onUploadCompleted();
                        }
                        return _uploadTask.isInProgress
                            ? Container(
                                height: mq.size.height * 0.35,
                                width: mq.size.width * 0.7,
                                color: Colors.black.withOpacity(0.54),
                                child:
                                    Center(child: CupertinoActivityIndicator()),
                              )
                            : Container(height: 0, width: 0);
                      },
                    ),
                    if (widget.message.content == null ||
                        widget.message.content == '')
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildBottomDetails(context),
                      ),
                  ],
                ),
                if (widget.message.content != null &&
                    widget.message.content != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 1),
                    child: _buildBubbleContent(context),
                  )
              ],
            ),
            if (widget.message.content != null && widget.message.content != '')
              Padding(
                padding: const EdgeInsets.only(bottom: 1, right: 1),
                child: _buildSeenStatus(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDetails(BuildContext context) => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(5),
        height: 30,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.01),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: _buildSeenStatus(context),
      );

  String getTime() {
    int hour = widget.message.timeStamp.hour;
    int min = widget.message.timeStamp.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();

    return '$hRes:$mRes';
  }

  Widget _buildSeenStatus(BuildContext context) => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              getTime(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.done_all,
            color: (widget.message.isSeen != null && widget.message.isSeen)
                ? Theme.of(context).accentColor
                : Colors.white.withOpacity(0.35),
            size: 19,
          ),
        ],
      );

  Widget _buildBubbleContent(BuildContext context) {
    return SelectableText(
      widget.message.content,
      style: TextStyle(
        fontSize: 17,
        color: kBaseWhiteColor,
      ),
    );
  }
}
