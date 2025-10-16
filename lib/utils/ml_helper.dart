import 'package:foodie_ml/services/isolate_inference.dart';

class MLHelper {
  static final MLHelper _instance = MLHelper._internal();
  factory MLHelper() => _instance;
  MLHelper._internal();

  bool _initialized = false;
  IsolateInference? isolateInference;

  Future<void> initHelper() async {
    if (_initialized) return;

    await _loadLabels();
    await _loadModel();
    isolateInference = IsolateInference();
    await isolateInference!.start();

    _initialized = true;
  }

  Future<void> _loadLabels() async {
    // ...
  }

  Future<void> _loadModel() async {
    // ...
  }
}
