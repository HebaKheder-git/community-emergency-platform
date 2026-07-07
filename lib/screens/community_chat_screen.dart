// lib/screens/community_chat_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/chat_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/trust_verification/trust_verification_cubit.dart';
import '../cubits/trust_verification/trust_verification_state.dart';
import '../widgets/unverified_access_notice.dart';

// ════════════════════════════════════════════════════════════════════════════
// CommunityChatScreen
//
// Shown when "Chat" is tapped in the bottom navigation bar.
// Features:
//  • Group header with avatar + name + members subtitle
//  • Scrollable message list (text, image-attachment, quoted-reply bubbles)
//  • Outgoing (right-aligned, borderless) and incoming (left-aligned, white
//    card) bubble styles matching the Figma exactly
//  • Tick / double-tick read status for outgoing messages
//  • Input bar with paperclip (attach), message field, emoji-moon icon, and
//    a mic icon (idle) that swaps to a send arrow when text is present
//  • Image picker integration: selecting a photo appends an image-attachment
//    bubble to the list
//  • Voice recording UX: long-press mic → shows a recording indicator (no
//    real audio recording — wire up when Qubit / audio plugin is ready)
// ════════════════════════════════════════════════════════════════════════════

class CommunityChatScreen extends StatefulWidget {
  /// Bottom-nav index tracking; the parent HomeScreen passes this down so
  /// the nav bar stays in sync across tabs.
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  /// Whether there are unread messages from others (controls the red dot).
  final bool hasUnread;

  const CommunityChatScreen({
    super.key,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.hasUnread = false,
  });

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  // ── state ──────────────────────────────────────────────────────────────────
  final List<ChatMessage> _messages = List.from(mockChatMessages);
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  bool _hasText = false;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  String _now() {
    final t = DateTime.now();
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _sendText() {
    final body = _textController.text.trim();
    if (body.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: UniqueKey().toString(),
        sender: MessageSender.me,
        type: MessageType.text,
        text: body,
        time: _now(),
        isRead: false,
      ));
    });
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final List<XFile> picked =
        await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      for (final xfile in picked) {
        final name = xfile.name;
        final bytes =
            File(xfile.path).lengthSync(); // approx size
        final kb = (bytes / 1024).toStringAsFixed(1);
        _messages.add(ChatMessage(
          id: UniqueKey().toString(),
          sender: MessageSender.me,
          type: MessageType.image,
          fileName: name,
          fileSize: '$kb KB',
          imageUrl: xfile.path,
          time: _now(),
          isRead: false,
        ));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _startRecording() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordSeconds++);
    });
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    if (!_isRecording) return;
    final duration =
        '${(_recordSeconds ~/ 60).toString().padLeft(1, '0')}:${(_recordSeconds % 60).toString().padLeft(2, '0')}';
    setState(() {
      _isRecording = false;
      if (_recordSeconds >= 1) {
        _messages.add(ChatMessage(
          id: UniqueKey().toString(),
          sender: MessageSender.me,
          type: MessageType.voice,
          voiceDuration: duration,
          time: _now(),
          isRead: false,
        ));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      // ── Header ──────────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Group avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryRed,
                      width: 1.5,
                    ),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF0EF),
                    child: Icon(
                      Icons.group_outlined,
                      color: AppColors.primaryRed,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Group name + members
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Group',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'You, Zein and Yosef',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Info icon (placeholder)
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded,
                      color: AppColors.textGrey, size: 24),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),

      body: BlocBuilder<TrustVerificationCubit, TrustVerificationState>(
        builder: (context, state) {
          final verified = state.data.isApproved;
          if (!verified){
            return UnverifiedAccessNotice();}
          return Column(
        children: [
          // ── Message list ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final prevMsg = index > 0 ? _messages[index - 1] : null;

                // Show sender name only when it changes in a run of incoming
                final showSenderName = msg.sender == MessageSender.other &&
                    msg.senderName.isNotEmpty &&
                    (prevMsg == null ||
                        prevMsg.senderName != msg.senderName ||
                        prevMsg.sender != MessageSender.other);

                return _ChatBubble(
                  message: msg,
                  showSenderName: showSenderName,
                );
              },
            ),
          ),

          // ── Recording indicator ───────────────────────────────────────────
          if (_isRecording) _RecordingBar(seconds: _recordSeconds),

          // ── Input bar ─────────────────────────────────────────────────────
          _ChatInputBar(
            controller: _textController,
            hasText: _hasText,
            onAttach: _pickImage,
            onSend: _sendText,
            onMicStart: _startRecording,
            onMicEnd: _stopRecording,
          ),
        ],
      );
    },
  ),

      // ── Bottom Nav ─────────────────────────────────────────────────────────
      bottomNavigationBar: SoteriaBottomNav(
        selectedIndex: widget.selectedNavIndex,
        onTap: widget.onNavTap,
        chatHasUnread: false, // already ON this screen, so clear the dot
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _ChatBubble
// ════════════════════════════════════════════════════════════════════════════

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSenderName;

  const _ChatBubble({
    required this.message,
    required this.showSenderName,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == MessageSender.me;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) const Spacer(flex: 2),
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender name label for incoming messages
                if (showSenderName)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                _buildBubbleContent(isMe),
              ],
            ),
          ),
          if (!isMe) const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(bool isMe) {
    switch (message.type) {
      case MessageType.text:
        return _TextBubble(message: message, isMe: isMe);
      case MessageType.image:
        return _ImageBubble(message: message, isMe: isMe);
      case MessageType.voice:
        return _VoiceBubble(message: message, isMe: isMe);
      case MessageType.file:
        return _FileBubble(message: message, isMe: isMe);
    }
  }
}

// ─── Text bubble ────────────────────────────────────────────────────────────

class _TextBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _TextBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft:
              isMe ? const Radius.circular(18) : const Radius.circular(4),
          bottomRight:
              isMe ? const Radius.circular(4) : const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quoted reply block
          if (message.replyToSenderName != null) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(
                    color: AppColors.primaryRed,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.replyToSenderName!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.replyToText ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Message text + time row
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  message.text ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _TimeAndTick(time: message.time, isMe: isMe, isRead: message.isRead),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Image attachment bubble ─────────────────────────────────────────────────

class _ImageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ImageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final hasLocalPath = message.imageUrl != null &&
        message.imageUrl!.isNotEmpty &&
        File(message.imageUrl!).existsSync();

    return Container(
      width: 230,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft:
              isMe ? const Radius.circular(18) : const Radius.circular(4),
          bottomRight:
              isMe ? const Radius.circular(4) : const Radius.circular(18),
        ),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail preview
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasLocalPath
                ? Image.file(
                    File(message.imageUrl!),
                    width: 90,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 90,
                    height: 70,
                    color: const Color(0xFFE8E8E8),
                    child: const Icon(Icons.image_outlined,
                        color: Color(0xFFADADAD), size: 32),
                  ),
          ),
          const SizedBox(height: 8),
          // File name
          Text(
            message.fileName ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 2),
          // File size + time + tick
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message.fileSize ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryRed,
                ),
              ),
              _TimeAndTick(
                  time: message.time, isMe: isMe, isRead: message.isRead),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Voice bubble ────────────────────────────────────────────────────────────

class _VoiceBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;

  const _VoiceBubble({required this.message, required this.isMe});

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: widget.isMe
              ? const Radius.circular(18)
              : const Radius.circular(4),
          bottomRight: widget.isMe
              ? const Radius.circular(4)
              : const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _playing = !_playing),
            child: Icon(
              _playing
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              color: AppColors.primaryRed,
              size: 34,
            ),
          ),
          const SizedBox(width: 8),
          // Waveform placeholder
          Row(
            children: List.generate(
              18,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height: (i % 4 == 0 ? 18 : i % 3 == 0 ? 14 : 8).toDouble(),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.message.voiceDuration ?? '0:00',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(width: 6),
          _TimeAndTick(
            time: widget.message.time,
            isMe: widget.isMe,
            isRead: widget.message.isRead,
          ),
        ],
      ),
    );
  }
}

// ─── Generic file bubble ─────────────────────────────────────────────────────

class _FileBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _FileBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: AppColors.primaryRed, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.fileName ?? 'File',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text(message.fileSize ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
          const SizedBox(width: 10),
          _TimeAndTick(
              time: message.time, isMe: isMe, isRead: message.isRead),
        ],
      ),
    );
  }
}

// ─── Time + tick widget ───────────────────────────────────────────────────────

class _TimeAndTick extends StatelessWidget {
  final String time;
  final bool isMe;
  final bool isRead;

  const _TimeAndTick({
    required this.time,
    required this.isMe,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
        ),
        if (isMe) ...[
          const SizedBox(width: 3),
          Icon(
            isRead ? Icons.done_all_rounded : Icons.done_rounded,
            size: 14,
            color: isRead
                ? AppColors.primaryRed
                : AppColors.textGrey,
          ),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _RecordingBar
// ════════════════════════════════════════════════════════════════════════════

class _RecordingBar extends StatelessWidget {
  final int seconds;

  const _RecordingBar({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final min = (seconds ~/ 60).toString().padLeft(1, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.mic_rounded, color: AppColors.primaryRed),
          const SizedBox(width: 10),
          Text(
            'Recording  $min:$sec',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Text(
            'Slide to cancel',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _ChatInputBar
// ════════════════════════════════════════════════════════════════════════════

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final VoidCallback onMicStart;
  final VoidCallback onMicEnd;

  const _ChatInputBar({
    required this.controller,
    required this.hasText,
    required this.onAttach,
    required this.onSend,
    required this.onMicStart,
    required this.onMicEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Paperclip / attach
            GestureDetector(
              onTap: onAttach,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.attach_file_rounded,
                    color: AppColors.primaryRed, size: 26),
              ),
            ),

            const SizedBox(width: 6),

            // Text field
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textDark),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                              fontSize: 15, color: AppColors.primaryRed),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    // Moon / emoji icon inside the field
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.nightlight_round,
                        color: AppColors.primaryRed.withOpacity(0.8),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Mic (idle) / Send (when text present)
            GestureDetector(
              onTap: hasText ? onSend : null,
              onLongPressStart: hasText ? null : (_) => onMicStart(),
              onLongPressEnd: hasText ? null : (_) => onMicEnd(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: hasText
                    ? const Icon(Icons.send_rounded,
                        key: ValueKey('send'),
                        color: AppColors.primaryRed,
                        size: 28)
                    : const Icon(Icons.mic_none_rounded,
                        key: ValueKey('mic'),
                        color: AppColors.primaryRed,
                        size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}