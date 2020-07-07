import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:whatsapp_clone/providers/person.dart';

class InitChatData {
  final Person person;
  final List<Message> messages;
  InitChatData({
    @required this.person,
    @required this.messages,
  });

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
}

class Message {
  String content;
  String fromId;
  String toId;
  DateTime timeStamp;

  Message({
    this.content,
    this.fromId,
    this.toId,
    this.timeStamp,
  });

  static Message fromSnapshot(DocumentSnapshot snapshot) {
    return Message(
      content: snapshot['content'],
      fromId: snapshot['fromId'],
      toId: snapshot['toId'],
      timeStamp: DateTime.parse(snapshot['date']),
    );
  }

  static toJson(Message message) {
    final map = {
      'content': message.content,
      'fromId': message.fromId,
      'toId': message.toId,
      'timeStamp': message.timeStamp.toIso8601String(),
    };
    return json.encode(map);
  }
}
