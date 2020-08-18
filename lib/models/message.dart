import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'dart:convert';

import 'package:whatsapp_clone/models/person.dart';

enum MessageType {
  Text,
  Image,
}

class InitChatData {
  final String groupId;
  final String userId;
  final String peerId;
  final Person person;
  final List<dynamic> messages;
  DocumentSnapshot lastDoc;
  int unreadCount;  
  ReplyColorPair replyColorPair;
  InitChatData({
    @required this.groupId,  
    @required this.userId,  
    @required this.peerId,  
    @required this.person,
    @required this.messages,
    this.lastDoc,
    this.unreadCount = 0,
    this.replyColorPair,
  });

  DB db = DB();

  void setLastDoc(DocumentSnapshot doc) {
    lastDoc = doc;
  }

  void addMessage(Message newMsg) {
    if (messages.length > 5) {
      print('removed ----------->${messages.last.content}');
      messages.removeLast();
    }

    messages.insert(0, newMsg);
    print('added ---------> ${newMsg.content}');
  }

  dynamic gettojson() {
    return Person.toJson(person);
  }

  dynamic getMessagesJson() {
    var res = [];
    messages.forEach((element) {
      res.add(Message.toJson(element));
    });
    return json.encode(res);
  }

  static toJson(InitChatData chatData) {
    final map = {
      'person': Person.toJson(chatData.person),
      'messages': chatData.getMessagesJson(),
    };
    return json.encode(map);
  }

  Future<void> fetchNewChats() async {
    final newData = await db.getNewChats(groupId, lastDoc);
    newData.documents.forEach((element) {
      print('added -------------> ${element['content']}');
      messages.add(Message.fromJson(element));
    });
    if (newData.documents.isNotEmpty) {
      lastDoc = newData.documents[newData.documents.length - 1];      
    }
  }
}

class ReplyMessage {
  String content;
  String replierId;
  String repliedToId;
  String type;

  ReplyMessage({
    this.content,
    this.replierId,
    this.repliedToId,
    this.type,
  });

  static toJson(ReplyMessage msg)   {
    return json.encode({
      "content": msg.content,
      "replierId": msg.replierId,
      "repliedToId": msg.repliedToId,
      "type": msg.type,
    });
  }

  static ReplyMessage fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      content: json
      ['content'],
      replierId: json['replierId'],
      repliedToId: json['repliedToId'],
      type: json['type'],
    );
  }
}

class Message {
  String content;
  String fromId;
  String toId;
  DateTime timeStamp;
  bool isSeen;
  String type;
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
      'mediaUrl': message.mediaUrl,
      'uploadFinished': message.uploadFinished,      
      'replyContent': message.replyContent,
      'replyType': message.replyType,
      'replyMsgSenderId': message.replyMsgSenderId,
      'reply': message.reply != null ? ReplyMessage.toJson(message.reply) : null,
    });
  }
}
