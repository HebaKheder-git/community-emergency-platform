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

/// Mock messages matching the Figma design exactly so the screen is
/// fully interactive without backend wiring.  Replace/clear this list
/// once Qubit is connected.
final List<ChatMessage> mockChatMessages = [
  // ── sent by "me" ──────────────────────────────────────────────────────────
  const ChatMessage(
    id: '1',
    sender: MessageSender.me,
    type: MessageType.text,
    text: 'look and see by urself',
    time: '10:10',
    isRead: true,
  ),
  const ChatMessage(
    id: '2',
    sender: MessageSender.me,
    type: MessageType.image,
    fileName: 'IMG_0475.PNG',
    fileSize: '2.4 MB',
    imageUrl: '', // placeholder — swap with real asset/network URL
    time: '10:15',
    isRead: true,
  ),

  // ── Zein replies with a quote of "me" ────────────────────────────────────
  const ChatMessage(
    id: '3',
    sender: MessageSender.other,
    senderName: 'Zein Alkhnaisee',
    type: MessageType.text,
    replyToSenderName: 'You',
    replyToText: 'Good morning!',
    text: 'Good morning!',
    time: '11:40',
    isRead: false,
  ),

  // ── sent by "me" ──────────────────────────────────────────────────────────
  const ChatMessage(
    id: '4',
    sender: MessageSender.me,
    type: MessageType.text,
    text: 'We need more help here',
    time: '11:43',
    isRead: true,
  ),

  // ── Yosef ─────────────────────────────────────────────────────────────────
  const ChatMessage(
    id: '5',
    sender: MessageSender.other,
    senderName: 'Yosef Aloosh',
    type: MessageType.text,
    text: 'There is a group of people coming right now',
    time: '11:45',
    isRead: false,
  ),
  const ChatMessage(
    id: '6',
    sender: MessageSender.other,
    senderName: '',
    type: MessageType.text,
    text: 'Is there fire?',
    time: '11:45',
    isRead: false,
  ),

  // ── sent by "me" ──────────────────────────────────────────────────────────
  const ChatMessage(
    id: '7',
    sender: MessageSender.me,
    type: MessageType.text,
    text: 'No, there is not .....',
    time: '11:50',
    isRead: true,
  ),
  const ChatMessage(
    id: '8',
    sender: MessageSender.me,
    type: MessageType.image,
    fileName: 'IMG_0483.PNG',
    fileSize: '2.8 MB',
    imageUrl: '',
    time: '11:51',
    isRead: true,
  ),
  const ChatMessage(
    id: '9',
    sender: MessageSender.me,
    type: MessageType.image,
    fileName: 'IMG_0484.PNG',
    fileSize: '2.6 MB',
    imageUrl: '',
    time: '11:51',
    isRead: false,
  ),
];