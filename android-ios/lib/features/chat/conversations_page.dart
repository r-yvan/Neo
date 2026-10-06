import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/neo_widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/social_repository.dart';

/// Inbox: every conversation the user is part of, newest activity first.
///
/// The backend exposes chat over REST only — there is no websocket gateway —
/// so this screen polls `/chat/conversations` on a timer while it is mounted.
class ConversationsPage extends ConsumerStatefulWidget {
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ConsumerState<ConversationsPage> {
  Timer? _timer;
  List<Conversation> _items = const <Conversation>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
    _timer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final List<Conversation> items =
          await ref.read(chatRepositoryProvider).conversations();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Messages', style: theme.textTheme.displayMedium),
                      ),
                      NeoIconButton(
                        icon: Icons.refresh_rounded,
                        tooltip: 'Refresh',
                        onPressed: _load,
                      ),
                    ],
                  ),
                ),
              ),
              ..._body(theme),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(ThemeData theme) {
    if (_loading && _items.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: const NeoLoading(),
        ),
      ];
    }
    if (_error != null && _items.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: NeoErrorState(message: _error!, onRetry: _load),
        ),
      ];
    }
    if (_items.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: NeoEmptyState(
            icon: Icons.forum_outlined,
            title: 'No conversations yet',
            message:
                'Message an owner from any listing to ask about pickup, delivery or quantities.',
          ),
        ),
      ];
    }
    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _ConversationTile(
              conversation: _items[index],
              onTap: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) => ChatPage(
                      peer: _items[index].user,
                      bookingId: _items[index].lastMessage.bookingId,
                    ),
                  ),
                );
                _load(silent: true);
              },
            ),
            childCount: _items.length,
          ),
        ),
      ),
    ];
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Message last = conversation.lastMessage;
    final bool unread = conversation.unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: NeoCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            NeoAvatar(
              initials: conversation.user.initials,
              imageUrl: conversation.user.profileImage,
              size: 48,
              ring: unread,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        Dates.relative(last.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    last.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: unread
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          unread ? AppFontWeight.medium : AppFontWeight.regular,
                    ),
                  ),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadii.pillAll,
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One-to-one thread.
///
/// Delivery is optimistic: the bubble appears immediately, then the server
/// copy replaces it. The thread re-polls on a short interval so a reply shows
/// up without a manual refresh.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.peer, this.bookingId});

  final UserRef peer;
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
    _timer = Timer.periodic(
      AppConfig.chatPollInterval,
      (_) => _load(silent: true),
    );
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
      final ChatRepository repo = ref.read(chatRepositoryProvider);
      final PaginatedList<Message> page =
          await repo.messages(widget.peer.id);
      if (!mounted) return;
      setState(() {
        _messages = page.items.reversed.toList();
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
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final String content = _input.text.trim();
    if (content.isEmpty || _sending) return;
    final String me = ref.read(sessionProvider).user?.id ?? '';

    setState(() {
      _sending = true;
      _input.clear();
      _messages = <Message>[
        ..._messages,
        Message(
          id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
          senderId: me,
          receiverId: widget.peer.id,
          content: content,
          isRead: false,
          bookingId: widget.bookingId,
          createdAt: DateTime.now(),
        ),
      ];
    });
    _jumpToBottom();

    try {
      final Message saved = await ref.read(chatRepositoryProvider).send(
            receiverId: widget.peer.id,
            content: content,
            bookingId: widget.bookingId,
          );
      if (!mounted) return;
      setState(() {
        _messages = <Message>[..._messages, saved];
        _sending = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages = _messages
            .where((Message m) => !m.id.startsWith('pending-'))
            .toList();
        _sending = false;
      });
      showNeoSnack(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String me = ref.watch(sessionProvider).user?.id ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: Row(
          children: [
            NeoAvatar(
              initials: widget.peer.initials,
              imageUrl: widget.peer.profileImage,
              size: 36,
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.peer.fullName, style: theme.textTheme.titleSmall),
                if (widget.bookingId != null)
                  Text('About a booking', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const NeoLoading()
                  : _error != null && _messages.isEmpty
                      ? NeoErrorState(message: _error!, onRetry: _load)
                      : _messages.isEmpty
                          ? const NeoEmptyState(
                              icon: Icons.waving_hand_outlined,
                              title: 'Say hello',
                              message:
                                  'Ask about pickup time, delivery or the condition of the items.',
                            )
                          : ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: _messages.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Message message = _messages[index];
                                final bool mine = message.senderId == me;
                                final bool previousMine =
                                    index > 0 && _messages[index - 1].senderId == me;
                                return _Bubble(
                                  message: message,
                                  mine: mine,
                                  grouped: previousMine,
                                );
                              },
                            ),
            ),
            _composer(theme),
          ],
        ),
      ),
    );
  }

  Widget _composer(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: 'Write a message…',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Material(
            color: _input.text.trim().isEmpty ? AppColors.grey300 : AppColors.accent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _sending ? null : _send,
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.mine,
    required this.grouped,
  });

  final Message message;
  final bool mine;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool pending = message.id.startsWith('pending-');

    return Padding(
      padding: EdgeInsets.only(top: grouped ? 3 : AppSpacing.xs),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: mine
                    ? (pending ? AppColors.accentPressed : AppColors.accent)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadii.lg),
                  topRight: const Radius.circular(AppRadii.lg),
                  bottomLeft: Radius.circular(mine ? AppRadii.lg : 5),
                  bottomRight: Radius.circular(mine ? 5 : AppRadii.lg),
                ),
                border: mine
                    ? null
                    : Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mine ? Colors.white : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.createdAt == null
                            ? ''
                            : Dates.time(message.createdAt!),
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10,
                          letterSpacing: 0,
                          color: mine
                              ? Colors.white.withValues(alpha: 0.75)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (mine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}