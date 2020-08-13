import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'dart:convert';

import 'package:whatsapp_clone/providers/person.dart';

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
  InitChatData({
    @required this.groupId,  
    @required this.userId,  
    @required this.peerId,  
    @required this.person,
    @required this.messages,
    this.lastDoc,
    this.unreadCount,
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

class Message {
  String content;
  String fromId;
  String toId;
  DateTime timeStamp;
  bool isSeen;
  String type;
  String mediaUrl;
  bool uploadFinished;
  bool hasReply;
  String replyContent;

  Message({
    this.content,
    this.fromId,
    this.toId,
    this.timeStamp,
    this.isSeen,
    this.type,
    this.mediaUrl,
    this.uploadFinished,
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
    });
  }
}
