import 'package:flutter/material.dart';

class Person {
  final String name;
  String textToShow = '';
  String imageUrl;

  Person({
    @required this.name,
    this.textToShow,
    this.imageUrl,
  });
}
