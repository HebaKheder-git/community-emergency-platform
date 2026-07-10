import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_exception.dart';
import '../../core/token_storage.dart';
import '../../models/chat_message.dart';
import '../../repositories/chat_repository.dart';
import 'chat_state.dart';

/// Drives CommunityChatScreen — home-group text chat only.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({ChatRepository? repository, TokenStorage? tokenStorage})
      : _repository = repository ?? ChatRepository(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        super(const ChatState());

  final ChatRepository _repository;
  final TokenStorage _tokenStorage;

  String? _myEmail;
  String? _myName;
  int? _myId; // NEW

  Future<void> loadMessages() async {
    emit(state.copyWith(status: ChatStatus.loading));
    _myId ??= await _tokenStorage.readId();       // NEW
    _myEmail ??= await _tokenStorage.readEmail();
    _myName ??= await _tokenStorage.readName();
    try {
      final page = await _repository.getHomeMessages();
      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: page.messages
            .map((dto) => chatMessageFromDto(dto, myId: _myId, myEmail: _myEmail, myName: _myName))
            .toList(),
      ));
    } on ApiException catch (e) {
      if (e.statusCode == 403) {
        emit(state.copyWith(status: ChatStatus.noHomeGroup));
      } else {
        emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.message));
      }
    }
  }

  /// Optimistically appends the message so the bubble shows immediately,
  /// then reconciles with the server's copy (id/time may change) — or
  /// rolls it back on failure.
  Future<void> sendMessage(String content) async {
  final trimmed = content.trim();
  if (trimmed.isEmpty || state.isSending) return;

  final optimisticId = 'local-${DateTime.now().microsecondsSinceEpoch}';
  final optimistic = ChatMessage(
    id: optimisticId,
    sender: MessageSender.me,
    type: MessageType.text,
    text: trimmed,
    time: _nowLabel(),
    isRead: false,
  );
  emit(state.copyWith(isSending: true, messages: [...state.messages, optimistic]));

  try {
    final dto = await _repository.sendHomeMessage(trimmed);
    final confirmed = chatMessageFromDto(dto, myEmail: _myEmail, myName: _myName, myId: _myId);
    final updated =
        state.messages.map((m) => m.id == optimisticId ? confirmed : m).toList();
    emit(state.copyWith(isSending: false, messages: updated));
  } on ApiException catch (e) {
    final rolledBack = state.messages.where((m) => m.id != optimisticId).toList();
    emit(state.copyWith(
      isSending: false,
      status: ChatStatus.failure,
      messages: rolledBack,
      errorMessage: e.message,
    ));
  } catch (e, st) {
    // NEW — catches parsing/runtime errors (e.g. a field-name mismatch in
    // ChatMessageDto.fromJson) that aren't ApiException. Without this,
    // isSending is left stuck at `true` forever and every future
    // sendMessage() call silently no-ops on the guard clause above.
    // ignore: avoid_print
    print('sendMessage unexpected error: $e\n$st');
    final rolledBack = state.messages.where((m) => m.id != optimisticId).toList();
    emit(state.copyWith(
      isSending: false,
      status: ChatStatus.failure,
      messages: rolledBack,
      errorMessage: 'Could not send message. Please try again.',
    ));
  }
}

  String _nowLabel() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}