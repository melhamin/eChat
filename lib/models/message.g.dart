// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    content: json['content'] as String,
    fromId: json['fromId'] as String,
    toId: json['toId'] as String,
    timeStamp: json['timeStamp'] as String,
    sendDate: json['sendDate'] == null
        ? null
        : DateTime.parse(json['sendDate'] as String),
    isSeen: json['isSeen'] as bool,
    type: _$enumDecodeNullable(_$MessageTypeEnumMap, json['type']),
    mediaType: _$enumDecodeNullable(_$MediaTypeEnumMap, json['mediaType']),
    mediaUrl: json['mediaUrl'] as String,
    uploadFinished: json['uploadFinished'] as bool,
    reply: json['reply'] == null
        ? null
        : ReplyMessage.fromJson(Map<String, dynamic>.from(json['reply'])),
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'content': instance.content,
      'fromId': instance.fromId,
      'toId': instance.toId,
      'timeStamp': instance.timeStamp,
      'sendDate': instance.sendDate?.toIso8601String(),
      'isSeen': instance.isSeen,
      'type': _$MessageTypeEnumMap[instance.type],
      'mediaType': _$MediaTypeEnumMap[instance.mediaType],
      'mediaUrl': instance.mediaUrl,
      'uploadFinished': instance.uploadFinished,
      'reply': instance.reply?.toJson(),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$MessageTypeEnumMap = {
  MessageType.Text: 'Text',
  MessageType.Media: 'Media',
};

const _$MediaTypeEnumMap = {
  MediaType.Photo: 'Photo',
  MediaType.Video: 'Video',
};
