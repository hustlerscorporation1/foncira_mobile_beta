import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/verification_provider.dart';
import '../services/gemini_service.dart';
import '../theme/colors.dart';

class Message {
  final String text;
  final bool isFromAgent;
  final DateTime timestamp;

  Message({required this.text, required this.isFromAgent, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class ChatSupportPage extends StatefulWidget {
  const ChatSupportPage({super.key});

  @override
  State<ChatSupportPage> createState() => _ChatSupportPageState();
}

class _ChatSupportPageState extends State<ChatSupportPage> {
  late List<Message> messages;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    messages = [];
    _initializeGreeting();
  }

  Future<void> _initializeGreeting() async {
    final authProvider = context.read<AuthProvider>();
    final verifProvider = context.read<VerificationProvider>();
    final isConnected = authProvider.isAuthenticated;

    if (isConnected &&
        verifProvider.verifications.isEmpty &&
        !verifProvider.isLoading) {
      try {
        await verifProvider.loadVerifications();
      } catch (_) {
        // Keep a graceful fallback greeting if loading verifications fails.
      }
    }

    if (!mounted) return;

    final firstName = _resolveFirstName(authProvider);
    final hasActiveVerification = isConnected && verifProvider.activeCount > 0;
    final dayPlus = _computeActiveDayPlus(verifProvider.activeVerifications);

    final greetingText = _buildGreeting(
      isConnected: isConnected,
      firstName: firstName,
      hasActiveVerification: hasActiveVerification,
      activeDayPlus: dayPlus,
    );

    setState(() {
      messages.add(Message(text: greetingText, isFromAgent: true));
    });

    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  String _buildGreeting({
    required bool isConnected,
    required String firstName,
    required bool hasActiveVerification,
    required int? activeDayPlus,
  }) {
    if (!isConnected) {
      return 'Bonjour ! Je suis l\'assistant FONCIRA. Comment puis-je vous aider ?';
    }

    if (hasActiveVerification) {
      final dayLabel = activeDayPlus != null
          ? 'J+$activeDayPlus'
          : 'quelques jours';
      if (firstName.isNotEmpty) {
        return 'Bonjour $firstName, votre dossier est en cours depuis $dayLabel. Vous avez une question sur l\'avancement ?';
      }
      return 'Bonjour, votre dossier est en cours depuis $dayLabel. Vous avez une question sur l\'avancement ?';
    }

    if (firstName.isNotEmpty) {
      return 'Bonjour $firstName, comment puis-je vous aider aujourd\'hui ?';
    }

    return 'Bonjour, comment puis-je vous aider aujourd\'hui ?';
  }

  String _resolveFirstName(AuthProvider authProvider) {
    final firstName = authProvider.currentUser?.firstName?.trim() ?? '';
    if (firstName.isNotEmpty) return firstName;

    final email = authProvider.currentUser?.email;
    if (email != null && email.contains('@')) {
      final prefix = email.split('@').first.trim();
      if (prefix.isNotEmpty) return prefix;
    }

    return '';
  }

  int? _computeActiveDayPlus(List<Map<String, dynamic>> activeVerifications) {
    DateTime? oldestSubmissionDate;

    for (final verification in activeVerifications) {
      final rawDate =
          verification['submitted_at'] ??
          verification['created_at'] ??
          verification['createdAt'];

      final parsedDate = rawDate is String
          ? DateTime.tryParse(rawDate)
          : rawDate is DateTime
          ? rawDate
          : null;

      if (parsedDate == null) continue;

      final localDate = parsedDate.toLocal();
      if (oldestSubmissionDate == null ||
          localDate.isBefore(oldestSubmissionDate)) {
        oldestSubmissionDate = localDate;
      }
    }

    if (oldestSubmissionDate == null) return null;

    final days = DateTime.now().difference(oldestSubmissionDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      messages.add(Message(text: userMessage, isFromAgent: false));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final authProvider = context.read<AuthProvider>();
      final verifProvider = context.read<VerificationProvider>();
      final firstName = _resolveFirstName(authProvider);
      final isConnected = authProvider.isAuthenticated;
      final hasActiveVerification =
          isConnected && verifProvider.activeCount > 0;
      final activeVerificationDayPlus = hasActiveVerification
          ? _computeActiveDayPlus(verifProvider.activeVerifications)
          : null;

      final conversationHistory = messages
          .where((msg) => msg.isFromAgent || msg != messages.last)
          .map(
            (msg) => {
              'role': msg.isFromAgent ? 'assistant' : 'user',
              'content': msg.text,
            },
          )
          .toList();

      final response = await GeminiService.sendMessage(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        userFirstName: firstName.isNotEmpty ? firstName : null,
        isConnected: isConnected,
        hasActiveVerification: hasActiveVerification,
        activeVerificationDayPlus: activeVerificationDayPlus,
      );

      if (!mounted) return;

      setState(() {
        messages.add(Message(text: response, isFromAgent: true));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add(
          Message(
            text:
                'Désolé, une erreur s\'est produite. Veuillez réessayer: ${e.toString()}',
            isFromAgent: true,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support FONCIRA',
              style: GoogleFonts.outfit(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Assistant disponible',
              style: GoogleFonts.inter(
                color: kSuccess,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == messages.length) {
                  return _buildTypingIndicator();
                }

                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kBorderDark, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kDarkCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kBorderDark, width: 1),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.inter(
                        color: kTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Votre message...',
                        hintStyle: GoogleFonts.inter(
                          color: kTextSecondary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 1,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isLoading ? kTextSecondary : kPrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kDarkBg,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: kDarkBg,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isFromAgent = message.isFromAgent;

    return Align(
      alignment: isFromAgent ? Alignment.centerLeft : Alignment.centerRight,
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isFromAgent ? kDarkCard : kPrimaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: isFromAgent
                    ? MarkdownBody(
                        data: message.text,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: GoogleFonts.inter(
                                color: kTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              strong: GoogleFonts.inter(
                                color: kTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              em: GoogleFonts.inter(
                                color: kTextPrimary,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              listBullet: GoogleFonts.inter(
                                color: kTextPrimary,
                                fontSize: 14,
                              ),
                              blockquote: GoogleFonts.inter(
                                color: kTextSecondary,
                                fontSize: 14,
                              ),
                              code: GoogleFonts.jetBrainsMono(
                                color: kTextPrimary,
                                fontSize: 13,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: kDarkBg.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                      )
                    : Text(
                        message.text,
                        style: GoogleFonts.inter(
                          color: kDarkBg,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              )
              .animate()
              .slideX(begin: isFromAgent ? -0.2 : 0.2, end: 0, duration: 300.ms)
              .fade(),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kDarkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildTypingDot(index),
                ),
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 300.ms);
  }

  Widget _buildTypingDot(int index) {
    return Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: kTextSecondary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.3, 1.3),
          delay: Duration(milliseconds: index * 150),
          duration: 600.ms,
        );
  }
}
