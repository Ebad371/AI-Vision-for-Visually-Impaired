import 'dart:async';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AI for Vision Impaired'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  ImagePicker imagePicker;
  ImageLabeler imageLabeler;
  String result = '';
  String result2 = '';
  String to_speak = '';
  Timer _timer;
  FlutterTts flutterTts = FlutterTts();
  List<String> resultList = [];
  List<String> resultListLast = [];
  String currentElement;
  bool isSpeaking = false;

  void initializeTts() {
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
    flutterTts.setErrorHandler((message) {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    imageLabeler = GoogleMlKit.vision.imageLabeler();
  }

  Future<void> chooseImageFromCamera() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);

    _image = File(pickedFile.path);
    setState(() {});
    doImageLabeling();
  }

  Future _speak() async {
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.6);
    flutterTts.speak(to_speak);
  }

  void _stop() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  doImageLabeling() async {
    final inputImage = InputImage.fromFile(_image);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result = '';
    result2 = '';
    to_speak = '';

    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;

      setState(() {
        if (text != "Musical instrument") {
          result +=
              text + "        " + confidence.toStringAsFixed(2) + " %" + "\n";
          result2 += "The probability of " +
              text +
              "        " +
              "is " +
              confidence.toStringAsFixed(2) +
              " percent" +
              "\n";
          to_speak = '';

          to_speak += result2;
          print(to_speak);
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imageLabeler.close();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.help,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          )
        ],
        title: Text(widget.title),
        backgroundColor: Colors.brown,
        elevation: 0.0,
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
            backgroundColor: Colors.yellow,
            child: Icon(
              Icons.camera_alt_outlined,
              color: Colors.black,
              size: 50.0,
            ),
            onPressed: () {
              chooseImageFromCamera();
            }),
        SizedBox(
          height: 10,
        ),
        FloatingActionButton(
            backgroundColor: Colors.yellow,
            child: Icon(
              Icons.volume_up_outlined,
              color: Colors.black,
              size: 50.0,
            ),
            onPressed: () {
              _speak();
            }),
        SizedBox(
          height: 10,
        ),
        FloatingActionButton(
            backgroundColor: Colors.yellow,
            child: Icon(
              Icons.volume_off_outlined,
              color: Colors.black,
              size: 50.0,
            ),
            onPressed: () {
              _stop();
            }),
        SizedBox(
          height: 10,
        ),
      ]),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/background.jpg'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 28.0),
                child: Card(
                  color: Colors.transparent,
                  shadowColor: Colors.brown,
                  elevation: 30.0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Container(
                    child: _image != null
                        ? Image.file(
                            _image,
                            fit: BoxFit.cover,
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.image,
                              size: 200,
                            ),
                            color: Colors.brown[300],
                            onPressed: () {
                              chooseImageFromCamera();
                            },
                          ),
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     chooseImageFromCamera();
              //   },
              //   child: Text('Click Me!'),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     _speak();
              //   },
              //   child: Text('Speak!'),
              // ),
              // Card(
              //   color: Colors.black,
              //   shadowColor: Colors.white,
              //   elevation: 20.0,
              //   clipBehavior: Clip.antiAlias,
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20.0)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Container(
              //       height: 100,
              //       width: 200,
              //       child: Text(
              //         '$result',
              //         style: TextStyle(
              //             color: Colors.white,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 20.0),
              //       ),
              //     ),
              //   ),
              // )

              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$result',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
