import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AnalyzeScreen extends StatefulWidget {
  final String imageUri;
  final File img;

  const AnalyzeScreen({Key? key, required this.imageUri, required this.img}) : super(key: key);

  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {

  @override
  void initState() {
    analyzeImage();
  }

  Future<void> analyzeImage() async {
    var data = {
      "uri": widget.imageUri
    };
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('visionAnalysis');
    final results = await callable(data);
    print(results.data);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { Navigator.of(context).pop(); },
      child: Image.file(
        widget.img,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      )
    );
  }
}
