// lib/models/chat_message.dart

/// Who sent the message.
enum MessageSender {
  /// The current logged-in user.
  me,

  /// Any other participant in the group.
  other,
}

/// The type of content carried by a [ChatMessage].
enum MessageType {
  text,
  image, // an uploaded image / photo
  file,  // any non-image file attachment
  voice, // audio recording
}




/// A single message inside the Community Group chat.
/// When Qubit is wired up, replace the constructor with a fromJson / toJson
/// factory — the field names and types below should stay stable.
class ChatMessage {
  final String id;
  final MessageSender sender;
  final MessageType type;

  /// Display name of the sender (empty string when [sender] == [MessageSender.me]).
  final String senderName;

  /// For [MessageType.text]: the plain text body.
  final String? text;

  /// For [MessageType.image]: local file path or remote URL.
  final String? imageUrl;

  /// For [MessageType.file]: the file name shown in the bubble.
  final String? fileName;

  /// For [MessageType.file] or [MessageType.image]: human-readable size string.
  final String? fileSize;

  /// For [MessageType.voice]: duration label, e.g. "0:23".
  final String? voiceDuration;

  /// If non-null, this message is a reply to another message.
  final String? replyToSenderName;
  final String? replyToText;

  /// HH:mm time string shown in the bubble.
  final String time;

  /// Whether the message was read by others (shown as double tick for [MessageSender.me]).
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.type,
    this.senderName = '',
    this.text,
    this.imageUrl,
    this.fileName,
    this.fileSize,
    this.voiceDuration,
    this.replyToSenderName,
    this.replyToText,
    required this.time,
    this.isRead = false,
  });
}

/// Raw shape returned by GET/POST /emergency/chat.
///
/// ⚠️ ASSUMPTION FLAG: no sample response in the collection for either
/// endpoint. Assuming a Laravel-typical shape:
/// { "id": 12, "content": "hi", "user": { "id": 5, "name": "Yosef" },
///   "created_at": "2026-07-10T10:15:00Z" }
/// Parsed defensively with fallback key names. The sender-identity field
/// especially needs confirming — it's what tells the UI "is this bubble
/// mine."
class ChatMessageDto {
  final String id;
  final int? senderId;
  final String? senderName;
  final String? senderEmail;
  final String content;
  final DateTime? createdAt;

  const ChatMessageDto({
    required this.id,
    this.senderId,
    this.senderName,
    this.senderEmail,
    required this.content,
    this.createdAt,
  });

//  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
//    final user = (json['user'] is Map<String, dynamic>)
//        ? json['user'] as Map<String, dynamic>
//        : null;
//    int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
//
//    return ChatMessageDto(
//      id: (json['id'] ?? '').toString(),
//      senderId: toInt(user?['id'] ?? json['user_id'] ?? json['sender_id']),
//      senderName: (user?['name'] ?? json['sender_name']) as String?,
//      senderEmail: (user?['email'] ?? json['sender_email']) as String?,
//      content:
//          (json['content'] ?? json['message'] ?? json['text'] ?? '') as String,
//      createdAt: DateTime.tryParse(
//          (json['created_at'] ?? json['time'] ?? '').toString()),
//    );
//  }
//}

factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
  final sender = (json['sender'] is Map<String, dynamic>)
        ? json['sender'] as Map<String, dynamic>
        : null;

  int? toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

  return ChatMessageDto(
    id: (json['id'] ?? '').toString(),
    senderId: toInt(sender?['id']),
    senderName: sender?['name'] as String?,
    senderEmail: sender?['email'] as String?,
    content: (json['content'] ?? '') as String,
    createdAt: DateTime.tryParse(
      (json['sent_at'] ?? '').toString(),
    ),
  );
}
}

/// GET /emergency/chat response — handles a few possible envelope shapes
/// defensively (flat data:[...], nested data.data:[...] from a Laravel
/// paginator, or data.messages:[...]).
class ChatMessagePage {
  final List<ChatMessageDto> messages;
  final int currentPage;
  final int lastPage;
  final int total;

  const ChatMessagePage({
    this.messages = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory ChatMessagePage.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] is List)
        ? json['data'] as List
        : (json['messages'] is List)
            ? json['messages'] as List
            : const [];

    final meta = (json['meta'] is Map<String, dynamic>)
        ? json['meta'] as Map<String, dynamic>
        : const <String, dynamic>{};

    int toInt(dynamic v, int fallback) =>
        v == null ? fallback : (int.tryParse(v.toString()) ?? fallback);

    return ChatMessagePage(
      messages: list
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageDto.fromJson)
          .toList(),
      currentPage: toInt(meta['current_page'], 1),
      lastPage: toInt(meta['last_page'], 1),
      total: toInt(meta['total'], list.length),
    );
  }
}

/// Converts a raw [ChatMessageDto] into the UI's [ChatMessage]. "Is this
/// mine" is decided by comparing sender email (the identifier cached by
/// TokenStorage) first, falling back to name if the message has no email.
ChatMessage chatMessageFromDto(
  ChatMessageDto dto, {
  required int? myId,        // NEW — checked first
  required String? myEmail,
  required String? myName,
}) {
  final isMe = (dto.senderId != null && myId != null)
      ? dto.senderId == myId
      : (dto.senderEmail != null && myEmail != null)
          ? dto.senderEmail == myEmail
          : (dto.senderName != null && myName != null && dto.senderName == myName);

  final time = dto.createdAt != null
      ? '${dto.createdAt!.hour.toString().padLeft(2, '0')}:${dto.createdAt!.minute.toString().padLeft(2, '0')}'
      : '';

  return ChatMessage(
    id: dto.id,
    sender: isMe ? MessageSender.me : MessageSender.other,
    type: MessageType.text, // backend only supports text right now
    senderName: isMe ? '' : (dto.senderName ?? ''),
    text: dto.content,
    time: time,
    isRead: true, // backend has no read-receipt field yet — see note below
  );
}
