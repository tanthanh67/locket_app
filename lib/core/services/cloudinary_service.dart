import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Thay thông tin của bạn vào đây
  final _cloudinary = CloudinaryPublic(
    'YOUR_CLOUD_NAME',
    'YOUR_PRESET_NAME',
    cache: false,
  );

  Future<String?> uploadMedia(String filePath) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }
}
