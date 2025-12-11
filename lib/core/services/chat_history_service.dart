import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryService {
  static const String _storageKey = 'chat_history_v1';

  Future<void> saveMessages(List<({String text, bool isUser})> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = messages.map((msg) => {
      'text': msg.text,
      'isUser': msg.isUser,
    }).toList();
    
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<List<({String text, bool isUser})>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => (
        text: json['text'] as String, 
        isUser: json['isUser'] as bool
      )).toList();
    } catch (e) {
      // In case of error (e.g. migration), return empty
      return [];
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
