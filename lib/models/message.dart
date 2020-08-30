import 'package:json_annotation/json_annotation.dart';

import 'package:whatsapp_clone/consts.dart';
import 'package:whatsapp_clone/models/reply_message.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  String content;
  String fromId;
  String toId;
  String timeStamp;
  DateTime sendDate;
  bool isSeen;
  MessageType type;
  MediaType mediaType;
  String mediaUrl;
  bool uploadFinished;
  ReplyMessage reply;


  Message({
    this.content,
    this.fromId,
    this.toId,
    this.timeStamp,
    this.sendDate,
    this.isSeen,
    this.type,
    this.mediaType,
    this.mediaUrl,
    this.uploadFinished, 
    this.reply,
  });

  factory Message.fromJson(Map<String, dynamic> data) {          
    return _$MessageFromJson(data);  
  }

  static Map<String, dynamic> toJson(Message message) {
    return _$MessageToJson(message);  
  }
}
