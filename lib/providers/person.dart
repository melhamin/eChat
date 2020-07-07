import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Person {
  final String uid;
  final String name;  
  String imageUrl;

  Person({
    @required this.uid,
    @required this.name,    
    this.imageUrl,
  });

  static Person fromSnapshot(DocumentSnapshot snapshot) {
    // print('${snapshot.documentID}---${snapshot['username']}---${snapshot['imageUrl']}');
    return Person(
      uid: snapshot.documentID,
      name: snapshot['username'],
      imageUrl: snapshot['imageUrl'],      
    );
  }

  static toJson(Person person) {
    final map = {
      'uid': person.uid,
      'name': person.name,
      'imageUrl': person.imageUrl,      
    };
    return json.encode(map);
  }
}
