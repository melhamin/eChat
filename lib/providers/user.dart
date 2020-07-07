import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/providers/message.dart';

class User with ChangeNotifier {

  final _prefs = SharedPreferences.getInstance();

  FirebaseUser _user;
  String _userId;
  List<dynamic> _contacts = [];
  List<InitChatData> _chats = [];

  FirebaseUser get getUser {
    return _user;
  }

  String get getUserId {
    return _userId;
  }

  List<dynamic> get getContacts {
    return _contacts;
  }

  List<InitChatData> get chats {
    return _chats;
  }

  void addToChats(InitChatData chatData) {
    if(_chats.contains(chatData)) return;
    _chats.add(chatData);
    notifyListeners();
  }

  void addToContacts(String uid) {
    _contacts.add(uid);
    notifyListeners();
  }

  Future<void> getUserData() async {
    _user = await FirebaseAuth.instance.currentUser(); 
    _userId = _user.uid;    
    final userData = await Firestore.instance.collection('users').document(_userId).get();    
    userData.data['contacts'].forEach((elem) => _contacts.add(elem));
    notifyListeners();
  }

  void savePrefs() {
    
  }

}