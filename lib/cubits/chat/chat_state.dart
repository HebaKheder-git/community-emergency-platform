import 'package:equatable/equatable.dart';
import '../../models/chat_message.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  noHomeGroup, // 403 — verified, but not (yet) in an active home group
  failure,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;
  final int currentPage;     // NEW
  final bool hasMoreOlder;   // NEW
  final bool isLoadingMore;  // NEW

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMoreOlder = false,
    this.isLoadingMore = false,
  });

   ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    int? currentPage,
    bool? hasMoreOlder,
    bool? isLoadingMore,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [status, messages, isSending, errorMessage, currentPage, hasMoreOlder, isLoadingMore];
}