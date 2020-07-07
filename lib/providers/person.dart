import 'package:flutter/material.dart';

class Person {
  final String uid;
  final String name;
  String textToShow = '';  
  String imageUrl;

  Person({
    @required this.uid,
    @required this.name,
    this.textToShow,
    this.imageUrl,
  });
}
