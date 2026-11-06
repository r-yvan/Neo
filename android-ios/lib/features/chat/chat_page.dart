import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../profile/public_profile_page.dart';

/// One-to-one conversation.
///
/// The backend exposes chat over REST only (no websocket gateway in this
/// build), so the page polls [AppConfig.chatPollInterval] while mounted and
/// stops the timer the moment it is disposed.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.peer, this.bookingId});

  final UserRef peer;

  /// Optional booking reference; sent with messages so both sides can see
  /// which rental the conversation is about.
  final String? bookingId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _timer;

  List<Message> _messages = const <Message>[];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
    _timer = Timer.periodic(AppConfig.chatPollInterval,
        (Timer _) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final messages = await repo.messages(widget.peer.id);
      if (!mounted) return;
      setState(() {
        _messages = messages.items.reversed.toList();
        _error = null;
        _loading = false;
      });
      try {
        await repo.markConversationRead(widget.peer.id);
      } catch (_) {
        // Read receipts are best-effort.
      }
      _jumpToBottom();
    } on ApiException catch (e) {
      if (mounted && !silent) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final String text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .send(receiverId: widget.peer.id, content: text, bookingId: widget.bookingId);
      if (!mounted) return;
      _input.clear();
      await _load(silent: true);
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final bool ok = await confirmNeo(
      context,
      title: 'Delete message?',
      message: 'This removes the message for both of you.',
      confirmLabel: 'Delete',
    );
    if (ok != true) return;
    try {
      await ref.read(chatRepositoryProvider).deleteMessage(message.id);
      await _load(silent: true);
    } on ApiException catch (e) {
      if (mounted) showNeoSnack(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String myId = ref.watch(sessionProvider).user?.id ?? '';
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: AppRadii.smAll,
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (BuildContext _) =>
                  PublicProfilePage(userId: widget.peer.id),
            ),
          ),
          child: Row(
          children: <Widget>[
            NeoAvatar(
              initials: widget.peer.initials,
              imageUrl: widget.peer.profileImage,
              size: 36,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(widget.peer.fullName,
                      style: theme.textTheme.titleMedium, maxLines: 1),
                  Text('Tap for profile',
                      style: theme.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: _body(context, myId)),
            _inputBar(context),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, String myId) {
    final ThemeData theme = Theme.of(context);

    if (_loading && _messages.isEmpty) {
      return const Center(child: NeoLoading());
    }
    if (_error != null && _messages.isEmpty) {
      return NeoErrorState(message: _error!, onRetry: () => _load());
    }
    if (_messages.isEmpty) {
      return NeoEmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Say hello',
        message:
            'Ask ${widget.peer.fullName.split(' ').first} about availability, '
            'delivery or anything else before you book.',
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      itemCount: _messages.length,
      itemBuilder: (BuildContext context, int index) {
        final Message message = _messages[index];
        final bool mine = message.senderId == myId;

        final bool showDay = index == 0 ||
            !_isSameDay(_messages[index - 1].createdAt, message.createdAt);

        return Column(
          children: <Widget>[
            if (showDay) _dayDivider(context, message.createdAt),
            Align(
              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
              child: GestureDetector(
                onLongPress: mine ? () => _deleteMessage(message) : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.76,
                  ),
                  decoration: BoxDecoration(
                    color: mine
                        ? AppColors.accent
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: AppRadii.lgAll.copyWith(
                      bottomRight: mine
                          ? const Radius.circular(6)
                          : const Radius.circular(16),
                      bottomLeft: mine
                          ? const Radius.circular(16)
                          : const Radius.circular(6),
                    ),
                    border: mine
                        ? null
                        : Border.all(
                            color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        message.content,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: mine ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            message.createdAt == null
                                ? ''
                                : Dates.time(message.createdAt!),
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: mine
                                  ? Colors.white70
                                  : theme.textTheme.labelSmall?.color,
                            ),
                          ),
                          if (mine) ...<Widget>[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                              size: 13,
                              color: Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dayDivider(BuildContext context, DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: AppRadii.pillAll,
          ),
          child: Text(
            Dates.full(date),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }

  Widget _inputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Write a message…',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                border: const OutlineInputBorder(
                  borderRadius: AppRadii.pillAll,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          NeoIconButton(
            icon: Icons.send_rounded,
            tooltip: 'Send',
            filled: true,
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
