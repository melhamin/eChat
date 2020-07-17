import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/providers/message.dart';
import 'package:whatsapp_clone/providers/person.dart';

class User with ChangeNotifier {
  final _prefs = SharedPreferences.getInstance();

  FirebaseUser _user;
  String _userId;
  List<dynamic> _contacts = [];
  List<InitChatData> _chats = [];

  String _imageUrl;

  FirebaseUser get getUser {
    return _user;
  }

  String get imageUrl {
    return _imageUrl;
  }

  void  setImageUrl(String url) {
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

  void fetchChats() async {
    _chats.clear();
    _contacts.forEach((contact) async {
      String groupId = getGroupId(contact);
      // print('grouipid ------> $groupId');
      final peer =
          await Firestore.instance.collection('users').document(contact).get();
      final Person person = Person.fromSnapshot(peer);
      final messagesData = await Firestore.instance
          .collection('messages')
          .document(groupId)
          .collection(groupId)
          .orderBy('timeStamp', descending: true)
          .getDocuments();

      List<Message> messages = [];
      messagesData.documents.forEach((element) {
        messages.add(Message.fromSnapshot(element));
      });

      InitChatData chatData =
          InitChatData(groupId: groupId, person: person, messages: messages);

      _chats.add(chatData);
    });
    notifyListeners();
  }

  void bringChatToTop(String groupId) {

    // bring latest interacted contact and chat to top
    var ids = groupId.split('-');
    var peerId = ids.firstWhere((element) => element != _user.uid);

    var cIndex = _contacts.indexWhere((element) => element == peerId);
    _contacts.removeAt(cIndex);
    _contacts.insert(0, peerId);

    print('peer id ========> $peerId');

    Firestore.instance.collection('users').document(_user.uid).setData({
      'contacts': _contacts,
    }, merge: true);

    var index = _chats.indexWhere((element) => element.groupId == groupId);
    var temp = _chats[index];
    _chats.removeAt(index);
    _chats.insert(0, temp);
    notifyListeners();
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
    _contacts.insert(0, uid);
    notifyListeners();
  }

  Future<void> getUserData() async {
    _user = await FirebaseAuth.instance.currentUser();
    _userId = _user.uid;
    final userData =
        await Firestore.instance.collection('users').document(_userId).get();
    // print('user Data=============> ${userData}');
    userData.data['contacts'].forEach((elem) => _contacts.insert(0, elem));
    _imageUrl = _user.photoUrl;
    notifyListeners();
    // print(_contacts);
  }

  void savePrefs() {}
}
