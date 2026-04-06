import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/verification_provider.dart';

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

  @override
  void initState() {
    super.initState();
    messages = [];
    _initializeGreeting();
  }

  /// Génère un message d'accueil contextuel
  void _initializeGreeting() {
    final authProvider = context.read<AuthProvider>();
    final verifProvider = context.read<VerificationProvider>();

    String greetingText;
    final isConnected = authProvider.isAuthenticated;
    final firstName = authProvider.currentUser?.firstName ?? 'Client';
    final hasActiveVerification = verifProvider.activeCount > 0;

    if (!isConnected) {
      // Non connecté
      greetingText =
          'Bonjour! 👋 Bienvenue chez FONCIRA. Comment peut-on vous aider aujourd\'hui?';
    } else if (hasActiveVerification) {
      // Dossier en cours (simplifié pour simulation)
      greetingText =
          'Bonjour $firstName, votre dossier est en cours depuis J+3. Vous avez une question sur l\'avancement?';
    } else {
      // Pas de dossier actif
      greetingText =
          'Bonjour $firstName, comment peut-on vous aider aujourd\'hui?';
    }

    // Ajoute le message d'accueil avec animation
    setState(() {
      messages.add(Message(text: greetingText, isFromAgent: true));
    });

    // Scroll automatique vers le bas
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      messages.add(Message(text: userMessage, isFromAgent: false));
    });

    _scrollToBottom();

    // Simulation d'une réponse automatique
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        messages.add(
          Message(
            text:
                'Merci pour votre message. Un agent FONCIRA vous répondra sous peu! 🙏',
            isFromAgent: true,
          ),
        );
      });
      _scrollToBottom();
    });
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
          // Zone de messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.send_rounded, color: kDarkBg, size: 20),
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
                child: Text(
                  message.text,
                  style: GoogleFonts.inter(
                    color: isFromAgent ? kTextPrimary : kDarkBg,
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
}
