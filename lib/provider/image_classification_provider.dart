import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:foodie_ml/services/image_classification_service.dart';
import 'package:foodie_ml/utils/ml_helper.dart';

class ImageClassificationViewmodel extends ChangeNotifier {
  final ImageClassificationService _service;

  ImageClassificationViewmodel(this._service) {
    _service.initHelper();
  }

  Map<String, num> _classifications = {};
  Map<String, num> get classifications => Map.fromEntries(
    (_classifications.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .reversed
        .take(3),
  );

  // Future<void> runClassification(CameraImage camera) async {
  //   _classifications = await _service.inferenceCameraFrame(camera);
  //   notifyListeners();
  // }

  Future<void> close() async {
    await _service.close();
  }

  Future<void> runClassificationFromFile(String imagePath) async {
    try {
      _classifications = await _service.inferenceCameraFrame(imagePath);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error running classification: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }
}
