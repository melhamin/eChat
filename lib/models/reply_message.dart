import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../consts.dart';

part 'reply_message.g.dart';

@JsonSerializable()
class ReplyMessage {
  String content;
  String replierId;
  String repliedToId;
  MessageType type;

  ReplyMessage({
    this.content,
    this.replierId,
    this.repliedToId,
    this.type,
  });

   Map<String, dynamic> toJson()   {
    return _$ReplyMessageToJson(this);
  }

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    return _$ReplyMessageFromJson(json);
  }
}