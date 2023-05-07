import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:geolocator/geolocator.dart';
import 'package:piano/piano.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi Instruments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Multi Instruments'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterMidi flutterMidi = FlutterMidi();
  String path = 'assets/guitars.sf2';
  late Future<Position> position;

  @override
  void initState() {
    load(path);
    super.initState();
  }

  void load(String asset) async {
    flutterMidi.unmute(); // Optionally Unmute
    ByteData _byte = await rootBundle.load(asset);
    flutterMidi.prepare(sf2: _byte, name: path.replaceAll('assets/', ''));
  }

  Future<void> _makeCall(String num) async {
    Uri url = Uri(scheme: 'tel', path: num);
    await launchUrl(url);
  }

  Future<void> _sendEmail(String recipient, String subject, String body) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    await launchUrl(emailUri);
  }

  Future<void> _openGoogleWebsite(String url) async {
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: DropdownButton<String>(
            value: path,
            onChanged: (String? value) {
              print(value);
              setState(() {
                if (value != null) {
                  path = value;
                  load(value);
                }
              });
            },
            items: [
              DropdownMenuItem(
                child: Text('piano'),
                value: 'assets/Yamaha-Grand-Lite-SF-v1.1.sf2',
              ),
              DropdownMenuItem(
                child: Text('guitar'),
                value: 'assets/guitars.sf2',
              ),
              DropdownMenuItem(
                child: Text('flute'),
                value: 'assets/Expressive Flute SSO-v1.2.sf2',
              ),
            ],
          ),
        ),
        leadingWidth: 75,
        title: Text(widget.title),
        actions: [
          DropdownButton<String>(
            value: null,
            onChanged: (value){
              if (value == 'call') {
                _makeCall('0569330038');
              } else if (value == 'email') {
                _sendEmail('mody.aug@gmail.com', 'Subject', 'Body');
              } else if (value == 'web') {
                _openGoogleWebsite('https://mostaql.com/u/M0hammed_Essam');
              }
            },
            icon: const Icon(Icons.menu,color: Colors.black,textDirection: TextDirection.ltr),
            items: [
              DropdownMenuItem<String>(
                value: 'call',
                child: Row(
                  children: [
                    Icon(Icons.phone,color: Colors.black,),
                    SizedBox(width: 10,),
                    Text('Call')
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'web',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser,color: Colors.black,),
                    SizedBox(width: 10,),
                    Text('Website')
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email,color: Colors.black,),
                    SizedBox(width: 10,),
                    Text('email')
                  ],
                ),
              )
            ],
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: InteractivePiano(
        keyWidth: 60,
        noteRange: NoteRange.forClefs([Clef.Bass, Clef.Alto, Clef.Treble]),
        onNotePositionTapped: (p) {
          print(p.pitch);
          flutterMidi.playMidiNote(midi: p.pitch);
        },
      ),
    );
  }
}
