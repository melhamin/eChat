// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    imageUrl: json['imageUrl'] as String,
    about: json['about'] as String,
    aboutChangeDate: json['aboutChangeDate'] == null
        ? null
        : DateTime.parse(json['aboutChangeDate'] as String),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'imageUrl': instance.imageUrl,
      'about': instance.about,
      'aboutChangeDate': instance.aboutChangeDate?.toIso8601String(),
    };
