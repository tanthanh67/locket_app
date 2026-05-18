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
        "Viết một caption tiếng Việt cực ngắn dưới 10 từ cho ảnh này. "
        "Nếu không xác định được nội dung ảnh, chỉ trả về đúng câu: Khoảnh khắc tuyệt vời",
      );
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);
      final caption = response.text?.trim() ?? '';
      return caption.isEmpty ? "Khoảnh khắc tuyệt vời" : caption;
    } catch (e) {
      return "Khoảnh khắc tuyệt vời";
    }
  }
}
