import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AnalyzeScreen extends StatefulWidget {
  final String imageUri;
  final File img;

  const AnalyzeScreen({Key? key, required this.imageUri, required this.img}) : super(key: key);

  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  bool loading = true;
  String results = "";

  @override
  void initState() {
    analyzeImage();
  }

  Future<void> analyzeImage() async {
    var data = {
      "uri": widget.imageUri
    };
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('visionAnalysis');

    await callable(data).then((value) {
      print(value.data);
      setState(() {
        results = value.data;
        loading = false;
      });
    });
    String downloadURL = await firebase_storage.FirebaseStorage.instanceFor(
        bucket: 'echo-11de8-audio')
        .ref(results)
        .getDownloadURL();
    playSound(downloadURL);
  }

  playSound(String url) async {
    int result = await audioPlayer.play(url);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.release();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () { Navigator.of(context).pop(); },
          child: Image.file(
            widget.img,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          )
        ),
        loading ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withAlpha(150),
          ),
          height: 100,
          width: 100,
          child: const Center(
            child: CupertinoActivityIndicator(),
          )
        ) : Container()
      ]
    );
  }
}
