import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_clone/models/media_model.dart';
import 'package:whatsapp_clone/providers/message.dart';

class DB {
  Stream<QuerySnapshot> getContactsStream() {
    return Firestore.instance.collection('users').snapshots();
  }  

  Stream<DocumentSnapshot> getUserContactsStream(String uid) {
    return Firestore.instance.collection('users').document(uid).snapshots();
  }  

  Future<DocumentSnapshot> getUser(String id) {
    return Firestore.instance.collection('users').document(id).get();
  }

  DocumentReference createMessageDocument(
      String groupChatId, String documentName) {
    try {
      return Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(documentName);
    } catch (error) {
      print(
          '****************** DB createMessageDocument error **********************');
      print(error);
      throw error;
    }
  }

  Future<QuerySnapshot> getChatItemData(String groupId, [int limit = 20]) {
    try {
    return Firestore.instance
        .collection('messages')
        .document(groupId)
        .collection(groupId)
        .orderBy('timeStamp', descending: true)
        .limit(limit)
        .getDocuments();
    } catch (error) {
      print('****************** DB getChatItemData error **********************');
      throw error;
    }
  }

  void addMediaUrl(String groupId, String url, Message mediaMsg) {
    try {
      var docRef = Firestore.instance
          .collection('messages')
          .document(groupId)
          .collection('media')
          .document(mediaMsg.timeStamp.millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, MediaModel.fromMsgToMap(mediaMsg));
      });      
    } catch (error) {
      print('****************** DB addMediaUrl error **********************');
      print(error);
      throw error;
    }
  }

  Stream<QuerySnapshot> getMediaCount(String groupId) {
    try {
      return Firestore.instance
          .collection('messages')
          .document(groupId)
          .collection('media')
          .snapshots();
    } catch (error) {
      print('****************** DB getMediaCount error **********************');
      print(error);
      throw error;
    }
  }

  Stream<QuerySnapshot> getChatMediaStream(String groupId) {
    try {
      return Firestore.instance
          .collection('messages')
          .document(groupId)
          .collection('media')
          .snapshots();
    } catch (error) {
      print('****************** DB getChatMedia error **********************');
      print(error);
      throw error;
    }
  }

  void addNewMessage(DocumentReference docRef, dynamic data) {
    try {
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, data);
      });
    } catch (error) {
      print('****************** DB addNewMessage error **********************');
      print(error);
      throw error;
    }
  }

  void updateContacts(String userId, dynamic contacts) {
    try {
      Firestore.instance
          .collection('users')
          .document(userId)
          .setData({'contacts': contacts}, merge: true);
    } catch (error) {
      print(
          '****************** DB updateContacts error **********************');
      print(error);
      throw error;
    }
  }

  Future<DocumentSnapshot> addToPeerContacts(
      String userId, String newContact) async {
    var doc;
    var docRef;

    try {
      doc = Firestore.instance.collection('users').document(userId);
      docRef = await doc.get();

      var peerContacts = [];

      docRef.data['contacts'].forEach((elem) => peerContacts.add(elem));
      peerContacts.add(newContact);

      doc.setData({'contacts': peerContacts}, merge: true);
    } catch (error) {
      print(
          '****************** DB addToPeerContacts error **********************');
      print(error);
      throw error;
    }

    return docRef;
  }

  Stream<QuerySnapshot> getSnapshotsAfter(
      String groupChatId, DocumentSnapshot lastSnapshot) {
    try {
      return Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .startAfterDocument(lastSnapshot)          
          .orderBy('timeStamp')
          .snapshots();
    } catch (error) {
      print(
          '****************** DB getSnapshotsAfter error **********************');
      print(error);
      throw error;
    }
  } 

  Future<QuerySnapshot> getNewChats(
      String groupChatId, DocumentSnapshot lastSnapshot, [int limit = 20]) {
    try {
      return Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .startAfterDocument(lastSnapshot)   
          .limit(20)       
          .orderBy('timeStamp', descending: true)
          .getDocuments();
    } catch (error) {
      print(
          '****************** DB getSnapshotsAfter error **********************');
      print(error);
      throw error;
    }
  } 

  Stream<QuerySnapshot> getSnapshotsWithLimit(String groupChatId,
      [int limit = 10]) {
    try {
      return Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .limit(limit)
          .orderBy('timeStamp', descending: true)
          .snapshots();
    } catch (error) {
      print(
          '****************** DB getSnapshotsWithLimit error **********************');
      print(error);
      throw error;
    }
  }

  void updateMessageField(dynamic snapshot, String field, dynamic value) {
    try {
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshDoc = await transaction.get(snapshot.reference);
        await transaction.update(freshDoc.reference, {'$field': value});
      });
    } catch (error) {
      print(
          '****************** DB updateMessageField error **********************');
      print(error);
      throw error;
    }
  }

  // USER INFO

  void addNewUser(
      String userId, String imageUrl, String username, String email) {
    try {
      var doc = Firestore.instance.collection('users').document(userId);
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(doc, {
          'contacts': [],
          'imageUrl': imageUrl,
          'username': username,
          'email': email,
        });
      });
    } catch (error) {
      print('****************** DB addNewUser error **********************');
      print(error);
      throw error;
    }
  }

  Future<DocumentSnapshot> getUserDocRef(String userId) async {
    try {
      return Firestore.instance.collection('users').document(userId).get();
    } catch (error) {
      print('****************** DB getUserDocRef error **********************');
      print(error);
      throw error;
    }
  }

  void updateUserInfo(String userId, dynamic data) async {
    try {
      Firestore.instance.collection('users').document(userId).setData(data, merge: true);
    } catch (error) {
      print(
          '****************** DB updateUserInfo error **********************');
      print(error);
      throw error;
    }
  }
}
