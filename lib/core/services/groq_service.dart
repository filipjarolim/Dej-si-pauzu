import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  GroqService(this.apiKey);

  final String apiKey;
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final String _model = 'llama-3.3-70b-versatile';
  
  // Simple in-memory history management
  final List<Map<String, String>> _history = [];

  // Personality Modes
  final Map<String, String> _personaPrompts = {
    'zen': '''
**Persona:** Zen Master (Zenový mistr) 🧘
- **Tone:** Calm, philosophical, soothing, brief.
- **Style:** Use metaphors from nature. Focus on breathing and mindfulness.
- **Goal:** Induce calm and balance.
''',
    'friend': '''
**Persona:** Empathetic Friend (Empatický kamarád) 🤝
- **Tone:** Warm, casual, supportive, validating.
- **Style:** Use emojis, ask about feelings, be a good listener. "To mě mrzí", "Jsem tu pro tebe".
- **Goal:** Emotional validation and venting.
''',
    'coach': '''
**Persona:** Motivational Coach (Motivační kouč) 🔥
- **Tone:** Energetic, direct, action-oriented, encouraging.
- **Style:** Short sentences, exclamation marks, focus on small steps and victory. "Dokážeš to!", "Jdeme na to!".
- **Goal:** Action and energy lifting.
'''
  };

  String _currentPersona = 'zen'; // Default

  /// Updates the persona and resets history to apply new system prompt
  void setPersona(String personaKey) {
    if (_personaPrompts.containsKey(personaKey) && _currentPersona != personaKey) {
      _currentPersona = personaKey;
      clearHistory(); // Persona change requires context reset for cleanliness
    }
  }

  String get _systemPrompt {
    const String coreRules = '''
You are "Parťák" (Partner), a helpful AI assistant for the wellbeing app "Dej si pauzu".
**CORE RULE:**
- **LANGUAGE:** YOU MUST SPEAK **ONLY** CZECH (Čeština). NEVER use English.
- **GRAMMAR:** Use cohesive, natural, native-level Czech.
''';

    const String navigationRules = '''
**App Features & Navigation:**
Recommend these features when appropriate, using the EXACT navigation tags:
- **Breathing** (Dechová cvičení): [[NAVIGATE:/pause/breathing]]
- **Meditation** (Meditace): [[NAVIGATE:/pause/meditation]]
- **Stretching** (Protažení): [[NAVIGATE:/pause/stretching]]
- **Mood Tracking** (Sledování nálady): [[NAVIGATE:/mood]]
- **Tips** (Tipy pro zdraví): [[NAVIGATE:/tips]]
- **Profile/Stats** (Profil): [[NAVIGATE:/profile]]
''';

    final String personaSpecific = _personaPrompts[_currentPersona] ?? _personaPrompts['zen']!;

    return '$coreRules\n$personaSpecific\n$navigationRules';
  }

  /// Initializes the chat with the system prompt
  void _ensureInitialized() {
    if (_history.isEmpty) {
      _history.add({'role': 'system', 'content': _systemPrompt});
    }
  }

  /// Sends a message and returns the full response
  Future<String> sendMessage(String message) async {
    _ensureInitialized();
    _history.add({'role': 'user', 'content': message});

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _history,
          'temperature': 0.7, // Slightly creative
          'top_p': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': content});
        return content;
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Clears chat history
  void clearHistory() {
    _history.clear();
    // Re-init happens on next send
  }
}
