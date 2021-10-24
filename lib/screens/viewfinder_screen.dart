import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:illuminate/screens/analyze_screen.dart';
import 'package:path/path.dart';
import 'package:audioplayers/audioplayers.dart';

import '../main.dart';

class ViewfinderScreen extends StatefulWidget {
  const ViewfinderScreen({Key? key}) : super(key: key);

  @override
  _ViewfinderScreenState createState() => _ViewfinderScreenState();
}

class _ViewfinderScreenState extends State<ViewfinderScreen> with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  playSound() async {
    int result = await audioPlayer.play('assets/shutter.wav', isLocal: true);
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
      ResolutionPreset.ultraHigh,
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
    audioPlayer.release();
  }

  Widget cameraShutter(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(100),
      width: 125,
      child: Center(
        child:MaterialButton(
          onPressed: () { clickShutter(context); },
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

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  void clickShutter(BuildContext context) async {
    XFile? rawImage = await takePicture();
    File imageFile = File(rawImage!.path);
    String fileName = basename(imageFile.path);

    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instanceFor(
        bucket: 'echo-11de8-images');
    firebase_storage.Reference ref = storage.ref().child('/$fileName');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    firebase_storage.UploadTask uploadTask;
    //late StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    uploadTask = ref.putFile(File(imageFile.path), metadata);

    firebase_storage.UploadTask task= await Future.value(uploadTask);
    String uri = "";
    Future.value(uploadTask).then((value) => {
      print("gs:\\\\${value.ref.bucket}\\${value.ref.fullPath}")
    }).onError((error, stackTrace) => {
    });
    playSound();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnalyzeScreen(imageUri: uri,)),
    );
  }

  Widget wholeScreenButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GestureDetector(
        onTap: () { clickShutter(context); },
      )
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
                cameraShutter(context),
                wholeScreenButton(context),
              ]
          )
    );
  }
}
