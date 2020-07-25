import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/database/db.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';

class User with ChangeNotifier {
  final _prefs = SharedPreferences.getInstance();
  final db = DB();

  FirebaseUser _user;
  Person _userDetails;
  String _userId;
  List<dynamic> _contacts = [];
  List<InitChatData> _chats = [];

  String _imageUrl;
  bool _isLoading = true;

  bool get isLoading {
    return _isLoading;
  }

  FirebaseUser get getUser {
    return _user;
  }

  Person get userDetails {
    return _userDetails;
  }

  String get imageUrl {
    return _imageUrl;
  }

  void setImageUrl(String url) {
    _imageUrl = url;
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

  String getGroupId(String contact) {
    String groupId;
    if (_userId.hashCode <= contact.hashCode)
      groupId = '$_userId-$contact';
    else
      groupId = '$contact-$_userId';

    return groupId;
  }

  Future<dynamic> getUserData() async {
    _user = await FirebaseAuth.instance.currentUser();
    _userId = _user.uid;
    final userData = await db.getUser(_userId);
    _userDetails = Person.fromSnapshot(userData);
    _imageUrl = _user.photoUrl;

    if (userData.data != null)
      userData.data['contacts'].forEach((elem) => _contacts.insert(0, elem));
    notifyListeners();
    return true;
  }

  Future<InitChatData> getChatData(String peerId) async {
    String groupId = getGroupId(peerId);
    final peer = await db.getUser(peerId);
    final Person person = Person.fromSnapshot(peer);
    final messagesData = await db.getChatItemData(groupId);

    List<Message> messages = [];
    for (int i = 0; i < messagesData.documents.length; i++) {
      var tmp = Message.fromSnapshot(messagesData.documents[i]);
      messages.add(tmp);
    }

    final lastDoc = messagesData.documents[messagesData.documents.length - 1];

    InitChatData chatData = InitChatData(
      groupId: groupId,
      person: person,
      messages: messages,
      lastDoc: lastDoc,
    );
    return chatData;
  }

  Future<dynamic> fetchChats() async {
    _isLoading = true;
    _chats.clear();
    Future.forEach(_contacts, (contact) async {
      final chatData = await getChatData(contact);
      _chats.add(chatData);
    }).then((value) {
      _isLoading = false;
      notifyListeners();
    });
    return true;
  }

  void bringChatToTop(String groupId) {
    if (_chats.isNotEmpty && _chats[0].groupId != groupId) {
      // bring latest interacted contact and chat to top
      var ids = groupId.split('-');
      var peerId = ids.firstWhere((element) => element != _user.uid);

      var cIndex = _contacts.indexWhere((element) => element == peerId);
      _contacts.removeAt(cIndex);
      _contacts.insert(0, peerId);

      db.updateUserInfo(_user.uid, {
        {'contacts': _contacts}
      });

      var index = _chats.indexWhere((element) => element.groupId == groupId);
      var temp = _chats[index];
      _chats.removeAt(index);
      _chats.insert(0, temp);
      notifyListeners();
    }
  }

  void addToInitChats(InitChatData chatData) {
    if (_chats.contains(chatData)) return;
    _chats.insert(0, chatData);
    notifyListeners();
  }

  void addMessageToInitChats(InitChatData chatRoom, Message msg) {
    _chats
        .firstWhere((element) => element.person.uid == chatRoom.person.uid)
        .messages
        .insert(0, msg);
    // print('at cahts -------> ${x.messages[0].content}');
    notifyListeners();
  }

  void addToContacts(String uid) {
    _contacts.add(uid);
    notifyListeners();
  }

  void handleMessagesNotFromContacts(List<dynamic> newContacts) async {
    if (newContacts.length > _contacts.length) {
      for (int i = _contacts.length; i < newContacts.length; ++i) {
        final chatData = await getChatData(newContacts[i]);
        _chats.insert(0, chatData);
        _contacts.add(newContacts[i]);
      }
      notifyListeners();
    }
  }

  void clearChatsAndContacts() {
    // return Future.delayed(Duration.zero).then((value) {
    _chats.clear();
    _contacts.clear();
    // });
    // notifyListeners();
  }

  void savePrefs() {}
}
