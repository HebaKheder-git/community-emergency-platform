// lib/repositories/chat_repository.dart
//
// "Emergency — Group Chat (Trusted)" — home context only (guest
// intentionally not handled yet, per your note).
import '../core/api_client.dart';
import '../models/chat_message.dart';

class ChatRepository {
  ChatRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  static const String _homeContext = 'home';

  /// GET /emergency/chat?context=home
  /// Throws ApiException(statusCode: 403) if the caller has no active home
  /// group membership yet — ChatCubit turns that into a "join a group
  /// first" state instead of a generic error.
//  Future<ChatMessagePage> getHomeMessages({int page = 1, int perPage = 30}) {
//    return _api
//        .get('/emergency/chat?context=$_homeContext&per_page=$perPage&page=$page')
//        .then(ChatMessagePage.fromJson);
//  }
  Future<ChatMessagePage> getHomeMessages({int page = 1, int perPage = 30}) async {
    final res = await _api.get('/emergency/chat?context=$_homeContext&per_page=$perPage&page=$page');
    return ChatMessagePage.fromJson(res);
  }

  /// POST /emergency/chat — context: "home".
  /// Only `content` (plain text) is sent — no attachment endpoint exists
  /// in what you gave me yet.
  Future<ChatMessageDto> sendHomeMessage(String content) async {
    final res = await _api.post('/emergency/chat', body: {
      'context': _homeContext,
      'content': content,
    });
    final root =
        (res['data'] is Map<String, dynamic>) ? res['data'] as Map<String, dynamic> : res;
    return ChatMessageDto.fromJson(root);
  }
}