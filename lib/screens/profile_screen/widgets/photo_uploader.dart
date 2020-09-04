

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/services/storage.dart';

class PhotoUploader extends StatefulWidget {
  final File file;
  final String uid;
  final Function getUrl;
  PhotoUploader({
    @required this.file,
    @required this.uid,
    @required this.getUrl,
  });
  @override
  _PhotoUploaderState createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  Storage _storage;

  @override
  void initState() {
    super.initState();
    _storage = Storage();
  }

  StorageUploadTask _uploadTask;

  bool uploadCompleted = false;
  bool uploadStarted = false;

  void _startUpload() {
    setState(() {
      _uploadTask = _storage.getUploadTask(
          widget.file, 'profilePictures/${widget.uid}.png');
      uploadStarted = true;
    });
  }

  void getImageUrl() async {
    String url = await _storage.getUrl('profilePictures', '${widget.uid}.png');
    widget.getUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (widget.file != null) {
      return Column(
        children: [
          Container(
            height: mq.size.height * 0.7 - kToolbarHeight,
            child: Image.file(widget.file, fit: BoxFit.cover),
          ),
          if (_uploadTask != null)
            StreamBuilder<StorageTaskEvent>(
              stream: _uploadTask.events,
              builder: (ctx, snapshots) {
                var event = snapshots?.data?.snapshot;
                double progress = event == null
                    ? 0
                    : event.bytesTransferred / event.totalByteCount;
                return Column(
                  children: [
                    SizedBox(height: 10),
                    if (_uploadTask.isInProgress) CupertinoActivityIndicator(),
                    // SizedBox(height: 5),
                    // // LinearProgressIndicator(
                    // //   value: progress,
                    // // ),
                    // if (_uploadTask.isInProgress)
                    //   Text(
                    //       'Uploaded : ${(progress * 100).toStringAsFixed(2)} %'),
                  ],
                );
              },
            ),          
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: uploadStarted ? getImageUrl : _startUpload,
              child: Center(
                  child: Text(
                uploadStarted ? 'Save Changes' : 'Upload',
                style: TextStyle(
                    fontSize: 22, color: Theme.of(context).accentColor),
              )),
            ),
        ],
      );
    }
    return Text('Select an image!!!');
  }
}
