import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class ViewfinderScreen extends StatefulWidget {
  const ViewfinderScreen({Key? key}) : super(key: key);

  @override
  _ViewfinderScreenState createState() => _ViewfinderScreenState();
}

class _ViewfinderScreenState extends State<ViewfinderScreen> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
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

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
      await cameraController.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget cameraShutter() {
    return Container(
      color: Colors.black.withAlpha(100),
      width: 125,
      child: Center(
        child:MaterialButton(
          onPressed: () {},
          elevation: 2.0,
          color: Colors.white,
          child: const Icon(
            Icons.camera_alt,
            size: 35.0,
          ),
          padding: const EdgeInsets.all(15.0),
          shape: const CircleBorder(),
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
          body: Stack(
              children: [
                _isCameraInitialized
                  ? Transform.scale(
                    scale: 2.3 / controller!.value.aspectRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: controller!.buildPreview(),
                      ),
                    )
                  ) : Container(),
                cameraShutter(),
              ]
          )
    );
  }
}
