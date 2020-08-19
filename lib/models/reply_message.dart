import 'dart:convert';

import '../consts.dart';

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

  static toJson(ReplyMessage msg)   {
    return json.encode({
      "content": msg.content,
      "replierId": msg.replierId,
      "repliedToId": msg.repliedToId,
      "type": msg.type,
    });
  }

  static ReplyMessage fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      content: json
      ['content'],
      replierId: json['replierId'],
      repliedToId: json['repliedToId'],
      type: json['type'],
    );
  }
}