import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// AI 챗봇 - 상품 문의
class AiChatScreen extends StatefulWidget {
  final String productId;
  final String? initialColor;

  const AiChatScreen({
    super.key,
    required this.productId,
    this.initialColor,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final ValueNotifier<bool> _hasText = ValueNotifier(false);

  Product? _product;
  bool _isTyping = false;

  static const List<_SuggestedQuestion> _suggestedQuestions = [
    _SuggestedQuestion('다른 색상 추천해줘', Icons.palette_outlined),
    _SuggestedQuestion('비슷한 디자인 있어?', Icons.style_outlined),
    _SuggestedQuestion('저에게 잘 어울릴까요?', Icons.auto_awesome_outlined),
    _SuggestedQuestion('수납력은 어떤가요?', Icons.work_outline),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _hasText.value = _controller.text.trim().isNotEmpty;
    });
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final service = context.read<ProductService>();
    final product = await service.fetchProductById(widget.productId);
    if (!mounted) return;
    setState(() {
      _product = product;
      _messages.add(
        _ChatMessage(
          text: product != null
              ? '안녕하세요! "${product.name}"에 대해 궁금하신 점을 물어보세요.\n'
                  '사이즈, 소재, 관리 방법, 색상 조합 등 무엇이든 답변해 드릴게요.'
              : '안녕하세요! 무엇을 도와드릴까요?',
          isUser: false,
        ),
      );
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 백엔드(/api/v1/ai-chat)에 실제로 질문을 보낸다.
    // (서버에 AI 키가 설정 안 돼있으면 서버가 알아서 대체 응답을 준다.)
    String reply;
    try {
      final data = await ApiClient.instance.post('/ai-chat', body: {
        'productId': widget.productId,
        'message': text,
      }) as Map<String, dynamic>;
      reply = data['reply'] as String;
    } catch (_) {
      reply = _mockReply(text);
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });
    _scrollToBottom();
  }

  String _mockReply(String question) {
    final name = _product?.name ?? '이 상품';
    return '"$name" 관련 답변입니다 (Mock 응답).\n'
        '실제 서비스에서는 AI가 상품 정보를 바탕으로 상세히 답변드립니다.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _hasText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const _AiAvatar(size: 34),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI 컨시어지', style: AppTypography.h2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '온라인',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            _SuggestedQuestions(
              questions: _suggestedQuestions,
              onSelected: (question) => _handleSend(question),
            ),
            _ChatInputBar(
              controller: _controller,
              hasText: _hasText,
              onSend: () => _handleSend(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedQuestion {
  final String label;
  final IconData icon;

  const _SuggestedQuestion(this.label, this.icon);
}

class _AiAvatar extends StatelessWidget {
  final double size;

  const _AiAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.ink,
            AppColors.ink.withValues(alpha: 0.65),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome,
        size: size * 0.5,
        color: AppColors.textOnDark,
      ),
    );
  }
}

class _SuggestedQuestions extends StatelessWidget {
  final List<_SuggestedQuestion> questions;
  final ValueChanged<String> onSelected;

  const _SuggestedQuestions({
    required this.questions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: questions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final question = questions[index];
            return GestureDetector(
              onTap: () => onSelected(question.label),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      question.icon,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      question.label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.68,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser ? null : Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUser ? 0.10 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: AppTypography.body.copyWith(
          color: isUser ? AppColors.textOnDark : AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: Alignment.centerRight,
          child: bubble,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _AiAvatar(size: 26),
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _AiAvatar(size: 26),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final t = (_controller.value - i * 0.2) % 1.0;
                    final scale = 0.6 + 0.4 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
                    return Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> hasText;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.hasText,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                cursorColor: AppColors.ink,
                decoration: InputDecoration(
                  hintText: '무엇이든 물어보세요...',
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  isDense: true,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<bool>(
            valueListenable: hasText,
            builder: (context, active, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.ink,
                            AppColors.ink.withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  color: active ? null : AppColors.divider,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: active ? onSend : null,
                    child: Center(
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 20,
                        color: active
                            ? AppColors.textOnDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
