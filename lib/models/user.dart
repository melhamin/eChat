import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username; 
  String email; 
  String imageUrl;
  String about;
  DateTime aboutChangeDate;

  User({
    @required this.id,
    @required this.username, 
    this.email,   
    this.imageUrl,
    this.about,
    this.aboutChangeDate,
  });

  factory User.fromJson(Map<String, dynamic> data) {    
    return _$UserFromJson(data);
  }

  static Map<String, dynamic> toJson(User person) {    
    return _$UserToJson(person); 
  }
}
