import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/services/db.dart';

import 'message.dart';

class InitChatData {

  final DB db = DB();

  final String groupId;
  final String userId;
  final String peerId;
  final User person;
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
    this.unreadCount = 0,
  });  

  void setLastDoc(DocumentSnapshot doc) {
    lastDoc = doc;
  }

  void addMessage(Message newMsg) {
    if (messages.length > 20) {
      print('removed ----------->${messages.last.content}');
      messages.removeLast();
    }

    messages.insert(0, newMsg);
    print('added ---------> ${newMsg.content}');
  }

  dynamic gettojson() {
    return User.toJson(person);
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
      'person': User.toJson(chatData.person),
      'messages': chatData.getMessagesJson(),
    };
    return json.encode(map);
  }

  Future<bool> fetchNewChats() async {
    final newData = await db.getNewChats(groupId, lastDoc);
    await Future.delayed(Duration.zero).then((value) {
      newData.documents.forEach((element) {
      // print('new message added -------------> ${element['content']}');
      messages.add(Message.fromJson(element.data));      
    });

    if (newData.documents.isNotEmpty) {
      lastDoc = newData.documents[newData.documents.length - 1];
    }
    }).then((value) => value);    

    return true;
  }  
}
