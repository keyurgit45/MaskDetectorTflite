import 'package:flutter/material.dart';
import 'package:mask_detector_tflite/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mask Detector',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
