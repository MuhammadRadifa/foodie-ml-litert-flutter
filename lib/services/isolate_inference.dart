import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;
  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      final imageMatrix = _preprocessImage(
        isolateModel.imagePath,
        isolateModel.inputShape,
      );

      final input = [imageMatrix];
      final output = [List<int>.filled(isolateModel.outputShape[1], 0)];

      final result = _runInference(
        input,
        output,
        isolateModel.interpreterAddress,
      );

      final keys = isolateModel.labels;
      final Map<String, double> classification = {};
      for (int i = 0; i < keys.length; i++) {
        classification[keys[i]] = result[i].toDouble();
      }

      isolateModel.responsePort.send(classification);
    }
  }

  /// 🔹 Preprocessing untuk model uint8
  static List<List<List<int>>> _preprocessImage(
    String imagePath,
    List<int> inputShape,
  ) {
    final bytes = File(imagePath).readAsBytesSync();
    final image = image_lib.decodeImage(bytes)!;

    final resized = image_lib.copyResize(
      image,
      width: inputShape[1],
      height: inputShape[2],
    );

    final imageMatrix = List<List<List<int>>>.generate(
      resized.height,
      (y) => List<List<int>>.generate(resized.width, (x) {
        final pixel = resized.getPixel(x, y);
        // pastikan semua nilai bertipe int
        return <int>[pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
      }, growable: false),
      growable: false,
    );

    return imageMatrix;
  }

  static List<int> _runInference(
    List<List<List<List<int>>>> input,
    List<List<int>> output,
    int interpreterAddress,
  ) {
    final interpreter = Interpreter.fromAddress(interpreterAddress);
    interpreter.run(input, output);
    return output.first;
  }

  Future<void> close() async {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }
}

class InferenceModel {
  final String imagePath;
  final int interpreterAddress;
  final List<String> labels;
  final List<int> inputShape;
  final List<int> outputShape;
  late SendPort responsePort;

  InferenceModel({
    required this.imagePath,
    required this.interpreterAddress,
    required this.labels,
    required this.inputShape,
    required this.outputShape,
  });
}
