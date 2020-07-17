import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Person {
  final String uid;
  final String name; 
  String email; 
  String imageUrl;
  String about;
  DateTime aboutChangeDate;

  Person({
    @required this.uid,
    @required this.name, 
    this.email,   
    this.imageUrl,
    this.about,
    this.aboutChangeDate,
  });

  static Person fromSnapshot(DocumentSnapshot snapshot) {
    // print('${snapshot.documentID}---${snapshot['username']}---${snapshot['imageUrl']}');
    return Person(
      uid: snapshot.documentID,
      name: snapshot['username'],
      email: snapshot['email'],
      imageUrl: snapshot['imageUrl'],      
      about: snapshot['about'],  
      aboutChangeDate: snapshot['aboutChangeDate'] != null ? DateTime.tryParse(snapshot['aboutChangeDate'])?? DateTime.now() : DateTime.now(),
    );
  }

  static toJson(Person person) {    
    return json.encode({
      'uid': person.uid,
      'name': person.name,
      'email': person.email,
      'imageUrl': person.imageUrl,         
      'about': person.about,
      'aboutChangeDate': person.aboutChangeDate.toIso8601String(),
    });
  }
}
