import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/message_entity.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String text,
    required String senderId,
    required DateTime timestamp,
    required bool isMe,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}

extension MessageModelX on MessageModel {
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      text: text,
      senderId: senderId,
      timestamp: timestamp,
      isMe: isMe,
    );
  }
}
