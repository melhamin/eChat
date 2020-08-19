import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/reply_message.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
// part 'message.g.dart';

@JsonSerializable()
class Message {
  String content;
  String fromId;
  String toId;
  DateTime timeStamp;
  bool isSeen;
  MessageType type;
  PickedMediaType mediaType;
  String mediaUrl;
  bool uploadFinished;
  ReplyMessage reply;

  String replyContent;
  String replyType;
  String replyMsgSenderId;


  Message({
    this.content,
    this.fromId,
    this.toId,
    this.timeStamp,
    this.isSeen,
    this.type,
    this.mediaType,
    this.mediaUrl,
    this.uploadFinished, 
    this.replyContent,
    this.replyType,
    this.replyMsgSenderId,
    this.reply,
  });

  static Message fromJson(DocumentSnapshot snapshot) {
    return Message(
      content: snapshot['content'],
      fromId: snapshot['fromId'],
      toId: snapshot['toId'],
      timeStamp: DateTime.parse(snapshot['date']),
      isSeen: snapshot['isSeen'],
      type: snapshot['type'],
      mediaType: snapshot['mediaType'],
      mediaUrl: snapshot['mediaUrl'],
      uploadFinished: snapshot['uploadFinished'],  
      replyContent: snapshot['replyContent'],
      replyType: snapshot['replyType'],
      replyMsgSenderId: snapshot['replyMsgSenderId'],
      reply: snapshot['reply'] != null ? ReplyMessage.fromJson(json.decode(snapshot['reply'])) : null,
    );
  }

  static toJson(Message message) {
    return json.encode({
      'content': message.content,
      'fromId': message.fromId,
      'toId': message.toId,
      'timeStamp': message.timeStamp.toIso8601String(),
      'isSeen': message.isSeen,
      'type': message.type,
      'mediaType': message.mediaType,
      'mediaUrl': message.mediaUrl,
      'uploadFinished': message.uploadFinished,      
      'replyContent': message.replyContent,
      'replyType': message.replyType,
      'replyMsgSenderId': message.replyMsgSenderId,
      'reply': message.reply != null ? ReplyMessage.toJson(message.reply) : null,
    });
  }
}
