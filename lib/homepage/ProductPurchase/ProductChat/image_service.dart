import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageAndConvertToBase64() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    File imageFile = File(pickedFile.path);
    return base64Encode(await imageFile.readAsBytes());
  }
}
