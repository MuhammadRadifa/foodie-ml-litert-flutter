import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:foodie_ml/services/isolate_inference.dart';
import 'package:foodie_ml/utils/ml_helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' as image_lib;

class ImageClassificationService {
  final modelPath = 'assets/food.tflite';
  final labelsPath = 'assets/label.txt';
  Interpreter? _interpreter;
  List<String>? _labels;
  Tensor? _inputTensor;
  Tensor? _outputTensor;
  IsolateInference? isolateInference;

  bool _initialized = false;
  Future<void>? _initFuture;

  Future<void> initHelper() {
    // Gunakan future caching agar tidak dijalankan dua kali
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    await _loadLabels();
    await _loadModel();
    isolateInference = IsolateInference();
    await isolateInference!.start();

    _initialized = true;
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions()
        ..useNnApiForAndroid = true
        ..useMetalDelegateForIOS = true;

      _interpreter = await Interpreter.fromAsset(modelPath, options: options);

      _inputTensor = _interpreter!.getInputTensors().first;
      _outputTensor = _interpreter!.getOutputTensors().first;
    } catch (e) {
      print("❌ Error loading model: $e");
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelTxt = await rootBundle.loadString(labelsPath);
      _labels = labelTxt.split('\n');
    } catch (e) {
      print("❌ Error loading labels: $e");
    }
  }

  Future<Map<String, double>> inferenceCameraFrame(String imagePath) async {
    await initHelper(); // pastikan sudah inisialisasi

    var isolateModel = InferenceModel(
      imagePath: imagePath,
      interpreterAddress: _interpreter!.address,
      labels: _labels!,
      inputShape: _inputTensor!.shape,
      outputShape: _outputTensor!.shape,
    );

    ReceivePort responsePort = ReceivePort();
    isolateInference!.sendPort.send(
      isolateModel..responsePort = responsePort.sendPort,
    );

    var results = await responsePort.first;
    return results;
  }

  Future<Map<String, double>> inferenceImageFile(String imagePath) async {
    await initHelper(); // pastikan sudah siap

    final bytes = File(imagePath).readAsBytesSync();
    final image = image_lib.decodeImage(bytes)!;

    final resized = image_lib.copyResize(
      image,
      width: _inputTensor!.shape[1],
      height: _inputTensor!.shape[2],
    );

    final imageMatrix = List.generate(
      resized.height,
      (y) => List.generate(resized.width, (x) {
        final pixel = resized.getPixel(x, y);
        return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
      }),
    );

    final input = [imageMatrix];
    final output = [List<double>.filled(_outputTensor!.shape[1], 0)];

    _interpreter!.run(input, output);
    final result = output.first;

    final Map<String, double> classifications = {};
    for (int i = 0; i < _labels!.length; i++) {
      classifications[_labels![i]] = result[i];
    }

    return classifications;
  }

  Future<void> close() async {
    await isolateInference?.close();
  }
}
