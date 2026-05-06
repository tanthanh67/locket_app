import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  Future<String> generateCaption(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final prompt = TextPart(
        "Viết một caption cực ngắn (dưới 10 từ), hài hước hoặc 'deep' cho ảnh Locket này để gửi cho bạn thân:",
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);
      return response.text ?? "Vừa mới chụp xong! ✨";
    } catch (e) {
      return "Khoảnh khắc tuyệt vời! 📸";
    }
  }
}
