import 'package:cloud_firestore/cloud_firestore.dart';

class DB {
  Stream<QuerySnapshot> getContactsStream() {
    return Firestore.instance.collection('users').snapshots();
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

  Stream<QuerySnapshot> getSnapshotsWithLimit(String groupChatId, int limit) {
    try {
      return Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .limit(10)
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
      return getUserDocRef(userId).then((value) async {
        await Firestore.instance.runTransaction((transaction) async {
          await transaction.update(value.reference, data);
        });
      });
    } catch (error) {
      print(
          '****************** DB updateUserInfo error **********************');
      print(error);
      throw error;
    }
  }
}
