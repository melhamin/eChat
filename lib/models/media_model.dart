import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:whatsapp_clone/models/message.dart';

class MediaModel {
  final String url;
  final String fromId;
  final String toId;
  final DateTime timeStamp;

  MediaModel({
    @required this.url,
    @required this.fromId,
    @required this.toId,
    @required this.timeStamp,
  });

  static MediaModel fromJson(snapshot) => MediaModel(
        url: snapshot['url'],
        fromId: snapshot['fromId'],
        toId: snapshot['toId'],
        timeStamp: DateTime.parse(snapshot['timeStamp']),
      );

  static toJson(MediaModel media) => json.encode({
    'url': media.url,
    'fromId': media.fromId,
    'toId': media.toId,
    'timeStamp': media.timeStamp.toIso8601String(),
  });

  static fromMsgToMap(Message msg) => {
    'url': msg.mediaUrl,
    'fromId': msg.fromId,
    'toId': msg.toId,
    'timeStamp': msg.timeStamp.toIso8601String(),
  };
}
