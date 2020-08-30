// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyMessage _$ReplyMessageFromJson(Map<String, dynamic> json) {
  return ReplyMessage(
    content: json['content'] as String,
    replierId: json['replierId'] as String,
    repliedToId: json['repliedToId'] as String,
    type: _$enumDecodeNullable(_$MessageTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$ReplyMessageToJson(ReplyMessage instance) =>
    <String, dynamic>{
      'content': instance.content,
      'replierId': instance.replierId,
      'repliedToId': instance.repliedToId,
      'type': _$MessageTypeEnumMap[instance.type],
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
