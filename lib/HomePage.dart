import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  late File _image;
  late List _output;
  final imagepicker = ImagePicker();
  String src =
      "https://image.freepik.com/free-vector/realistic-medical-mask-concept_52683-36726.jpg";

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  detectimage(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _output = prediction!;
      loading = false;
    });
    print(_output);
  }

  pickimageCamera() async {
    var image = await imagepicker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  pickimageGallery() async {
    var image = await imagepicker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mask Detector using Tflite",
          style: GoogleFonts.lato(fontSize: 17),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              loading
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                      ),
                      padding: EdgeInsets.all(10),
                      child: Image.network(
                        src,
                        fit: BoxFit.fill,
                        height: 150,
                        width: 150,
                      ))
                  : Container(),
              SizedBox(
                height: 20,
              ),
              Container(
                  child: Text('Mask Detector',
                      style: GoogleFonts.abel(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ))),
              SizedBox(height: 30),
              Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      height: 50,
                      width: double.infinity,
                      // ignore: deprecated_member_use
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(0x1B1212),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Text('Camera',
                              style: GoogleFonts.roboto(fontSize: 18)),
                          onPressed: () {
                            pickimageCamera();
                          }),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0x1B1212),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Gallery',
                              style: GoogleFonts.roboto(fontSize: 18)),
                          onPressed: () {
                            pickimageGallery();
                          }),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              loading != true
                  ? Container(
                      child: Column(
                        children: [
                          Container(
                            height: 220,
                            padding: EdgeInsets.all(15),
                            child: Image.file(
                              _image,
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Text((_output[0]['label']).toString().substring(2),
                              style: GoogleFonts.roboto(fontSize: 22)),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Confidence: ' +
                                  (_output[0]['confidence'] * 100)
                                      .toString()
                                      .substring(0, 5) +
                                  " %",
                              style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: _output[0]['confidence'] < 0.50
                                      ? Colors.red
                                      : Colors.white))
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
