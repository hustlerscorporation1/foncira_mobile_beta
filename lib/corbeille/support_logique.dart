import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


class GeminiApiService {
  final String _apiKey = "AIzaSyAOfTJ7GrrEtIZhmOSmnbI6X_j-w2OettQ";
  late final GenerativeModel _model;

  GeminiApiService() {
    final systemInstruction = Content.system(
      "Tu es 'Agnis,' l'assistant virtuel expert de l'application AGNIGBAN~GNA. "
      "AGNIGBAN~GNA est une application mobile pour acheter et vendre des terrains au Togo. "
      "Ta mission est d'aider les utilisateurs de manière amicale, professionnelle et en français. "
      "Informations clés à connaître : "
      "- Pour vendre un terrain, l'utilisateur doit aller dans l'onglet 'Vendre' et suivre les étapes du formulaire. "
      "- Pour un problème ou un litige, il doit se rendre dans la section 'Litiges' de son profil. "
      "- Le support humain est disponible via le même profil, mais uniquement aux heures de bureau (8h-17h GMT). "
      "Ne réponds qu'aux questions concernant l'application AGNIGBAN~GNA et l'immobilier au Togo. "
      "Si on te pose une question hors sujet (politique, science, etc.), décline poliment en rappelant ton rôle.",
    );

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: systemInstruction,
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final chat = _model.startChat();
      final response = await chat.sendMessage(Content.text(userMessage));
      return response.text ?? "Désolé, une erreur est survenue.";
    } catch (e) {
      print("Erreur lors de l'appel à l'API Gemini: $e");
      return "Oups, je n'arrive pas à me connecter. Veuillez vérifier votre connexion internet et réessayer.";
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? quickReplies;

  ChatMessage({required this.text, required this.isUser, this.quickReplies});
}
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Bonjour ! Je suis Agnis, votre assistant virtuel pour AGNIGBAN~GNA. Comment puis-je vous aider ?",
      isUser: false,
      quickReplies: ["Vendre un terrain", "Signaler un problème"],
    ),
  ];
  final GeminiApiService _geminiService = GeminiApiService();
  bool _isLoading = false;

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    final userMessage = text;
    _controller.clear();

    setState(() {
      if (_messages.isNotEmpty && _messages.first.quickReplies != null) {
        _messages.first = ChatMessage(
          text: _messages.first.text,
          isUser: false,
        );
      }
      _messages.insert(0, ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    final botResponseText = await _geminiService.sendMessage(userMessage);
    final botResponse = ChatMessage(text: botResponseText, isUser: false);

    setState(() {
      _messages.insert(0, botResponse);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Client"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.only(top: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            if (_isLoading) _buildTypingIndicator(),
            if (!_isLoading &&
                _messages.isNotEmpty &&
                _messages.first.quickReplies != null)
              _buildQuickReplies(_messages.first.quickReplies!),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bubbleContent = Text(
      message.text,
      style: TextStyle(
        color: message.isUser ? Colors.white : Colors.black87,
        height: 1.4,
      ),
    );

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(20),
          ),
          child: bubbleContent,
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: bubbleContent,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildQuickReplies(List<String> replies) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      margin: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: replies.map((reply) {
          return ActionChip(
            label: Text(reply),
            onPressed: () => _handleSubmitted(reply),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 2,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: "Envoyer un message...",
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.green.shade700),
            onPressed: () => _handleSubmitted(_controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.7),
            radius: 16,
            child: Icon(
              Icons.support_agent,
              color: Colors.grey.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Agnis est en train d'écrire...",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
