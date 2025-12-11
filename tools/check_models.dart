import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyAuYRXCXeI1a_d9it9g4fY8N5RZvKew5n4';
  if (apiKey.isEmpty) {
    print('No API key provided.');
    return;
  }

  print('Listing models via HTTP...');
  try {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Available Models:');
      final models = data['models'] as List;
      for (final m in models) {
        print('- ${m['name']} (Supported methods: ${m['supportedGenerationMethods']})');
      }
    } else {
      print('Failed to list models. Status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error listing models: $e');
  }
}
