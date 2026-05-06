import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final _cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME']!,
    dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
  );

  Future<String?> uploadImage(String path) async {
    try {
      final res = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return res.secureUrl;
    } catch (e) {
      return null;
    }
  }
}
