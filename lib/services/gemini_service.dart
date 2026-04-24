import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service pour integrer l'API Gemini avec le contexte FONCIRA.
class GeminiService {
  static const String _apiBase =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// System prompt contenant les informations FONCIRA.
  static const String _systemPrompt =
      r'''Tu es l'assistant FONCIRA, une plateforme de verification fonciere au Togo qui cible la diaspora africaine (France, USA, Canada).

SERVICES ET PRIX :
- Vérification complète : $380 (≈ 250 000 FCFA) - rapport livré en 10 jours
- Pack Vérification + Accompagnement : $549 (≈ 325 000 FCFA)
- Accompagnement administratif seul : $175 (≈ 100 000 FCFA)

GARANTIE : On garantit un rapport complet, honnête et livré en 10 jours. Si on ne livre pas, vous êtes remboursé.

PARRAINAGE : $38 par ami référé qui complète une vérification.

PROCESSUS DE VÉRIFICATION :
- Étape 1 : Soumission du terrain (localisation, type de document, prix)
- Étape 2 : Préanalyse immédiate gratuite
- Étape 3 : Identité de la personne (prénom + WhatsApp)
- Étape 4 : Confirmation + assignation d'un agent
- Étape 5 : Paiement sécurisé
- Étape 6 : Suivi en temps réel J1/J3/J5/J7/J10
- Étape 7 : Rapport avec verdict clair
- Étape 8 : Décision post-rapport
- Étape 9 : Parrainage

JALONS DE SUIVI :
- J1 : Demande validée
- J3 : Vérification administrative
- J5 : Vérification coutumière
- J7 : Vérification du voisinage & Géomètre
- J10 : Décision du juriste & Rapport final

CONTEXTE TOGOLAIS : Au Togo, 7 terrains sur 10 presentent un risque juridique. Les documents existants sont : Titre foncier (le plus solide), Convention, Logement, Recu de vente, Aucun document.

STYLE DE REPONSE :
- Reponds toujours en francais.
- N'appelle jamais l'utilisateur "client".
- Adresse-toi a la personne avec "vous".
- Utilise du Markdown simple quand utile (ex: **gras**, listes courtes).
- Tu ne reponds qu'aux sujets lies a FONCIRA et a l'immobilier au Togo. Si la question est hors sujet, redirige poliment vers les sujets FONCIRA.''';

  /// Envoie un message a l'API Gemini et retourne la reponse.
  static Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    String? userFirstName,
    bool? isConnected,
    bool? hasActiveVerification,
    int? activeVerificationDayPlus,
  }) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY non configuree dans .env');
      }

      final messages = <Map<String, dynamic>>[];
      final personalizationContext = _buildPersonalizationContext(
        userFirstName: userFirstName,
        isConnected: isConnected,
        hasActiveVerification: hasActiveVerification,
        activeVerificationDayPlus: activeVerificationDayPlus,
      );

      messages.add({
        'role': 'user',
        'parts': [
          {'text': '$_systemPrompt\n\n$personalizationContext'},
        ],
      });

      messages.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Je suis bien l\'assistant FONCIRA. Comment puis-je vous aider ?',
          },
        ],
      });

      for (final msg in conversationHistory) {
        messages.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg['content']!},
          ],
        });
      }

      messages.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });

      final response = await http.post(
        Uri.parse('$_apiBase?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': messages,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;

          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String? ?? 'Pas de reponse';
          }
        }

        throw Exception('Reponse invalide de l\'API Gemini');
      }

      final errorBody = jsonDecode(response.body);
      final error = errorBody['error']['message'] ?? 'Erreur inconnue';
      throw Exception('Erreur API Gemini: $error');
    } catch (e) {
      print('Erreur GeminiService: $e');
      rethrow;
    }
  }

  static String _buildPersonalizationContext({
    String? userFirstName,
    bool? isConnected,
    bool? hasActiveVerification,
    int? activeVerificationDayPlus,
  }) {
    final lines = <String>[
      'CONSIGNES DE PERSONNALISATION (PRIORITAIRES) :',
      '- N\'appelle jamais l\'utilisateur "client".',
      '- Utilise "vous" ou le prenom quand il est connu.',
      '- Si PRENOM_UTILISATEUR est disponible, tu peux l\'utiliser naturellement en debut de reponse.',
    ];

    if (userFirstName != null && userFirstName.trim().isNotEmpty) {
      lines.add('- PRENOM_UTILISATEUR: ${userFirstName.trim()}');
    }

    if (isConnected != null) {
      lines.add('- UTILISATEUR_CONNECTE: ${isConnected ? 'oui' : 'non'}');
    }

    if (hasActiveVerification != null) {
      lines.add('- DOSSIER_EN_COURS: ${hasActiveVerification ? 'oui' : 'non'}');
    }

    if (activeVerificationDayPlus != null) {
      lines.add('- JOUR_DOSSIER: J+$activeVerificationDayPlus');
    }

    return lines.join('\n');
  }
}
