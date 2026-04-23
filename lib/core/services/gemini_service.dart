import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'YOUR_GEMINI_KEY',
  );

  Future<String> generateCaption(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final content = [
        Content.multi([
          TextPart("Viết 1 caption ngắn cho ảnh này để đăng Locket:"),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];
      final response = await _model.generateContent(content);
      return response.text ?? "";
    } catch (e) {
      return "";
    }
  }
}
