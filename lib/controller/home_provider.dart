import 'package:flutter/material.dart';
import 'package:foodie_ml/ui/camera_page.dart';
import 'package:image_picker/image_picker.dart';

class HomeProvider extends ChangeNotifier {
  String? imagePath;

  XFile? imageFile;

  void _setImage(XFile? value) {
    imageFile = value;
    imagePath = value?.path;
    notifyListeners();
  }

  void openCamera() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _setImage(pickedFile);
    }
  }

  void openGallery() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _setImage(pickedFile);
    }
  }

  void openCustomCamera(BuildContext context) async {
    final XFile? resultImageFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage()),
    );

    if (resultImageFile != null) {
      _setImage(resultImageFile);
    }
  }
}
