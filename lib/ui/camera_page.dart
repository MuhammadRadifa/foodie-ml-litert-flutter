import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData.dark(), child: _Body());
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with WidgetsBindingObserver {
  bool _isCameraInitialized = false;

  List<CameraDescription> _cameras = [];

  CameraController? controller;

  bool _isBackCameraSelected = true;

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await previousCameraController?.dispose();

    cameraController
        .initialize()
        .then((value) {
          if (mounted) {
            setState(() {
              controller = cameraController;

              _isCameraInitialized = controller!.value.isInitialized;
            });
          }
        })
        .catchError((e) {
          print('Error initializing camera: $e');
        });
  }

  void initCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    await onNewCameraSelected(_cameras.first);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    initCamera();

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController != null || !cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _isCameraInitialized
                ? CameraPreview(controller!)
                : const Center(child: CircularProgressIndicator()),
            Align(
              alignment: const Alignment(0.9, 0.9),
              child: FloatingActionButton(
                heroTag: "switch-camera",
                tooltip: "Switch Camera",
                onPressed: () => _onCameraSwitch(),
                child: const Icon(Icons.cameraswitch),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.9),
              child: FloatingActionButton(
                heroTag: "capture-image",
                tooltip: "Capture Image",
                onPressed: () => _onCaptureImage(),
                child: const Icon(Icons.camera_alt_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCaptureImage() async {
    final navigator = Navigator.of(context);

    final image = await controller?.takePicture();

    navigator.pop(image);
  }

  void _onCameraSwitch() {
    if (_cameras.length == 1) return;

    setState(() {
      _isCameraInitialized = false;
    });

    onNewCameraSelected(_cameras[_isBackCameraSelected ? 1 : 0]);

    setState(() {
      _isBackCameraSelected = !_isBackCameraSelected;
    });
  }
}
