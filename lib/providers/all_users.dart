import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:whatsapp_clone/providers/person.dart';


class AllUsers with ChangeNotifier {

  List<Person> _allUsers = [];

  List<Person> get allUsers {
    return _allUsers;
  }

  void fetchAllUsers() {
    _allUsers.clear();    
    Stream<QuerySnapshot> snapshots = Firestore.instance.collection('users').snapshots();
    snapshots.forEach((element) { 
      element.documents.forEach((element) { 
        _allUsers.add(Person.fromSnapshot(element));
      });
    });    

    print(_allUsers);

  }

}