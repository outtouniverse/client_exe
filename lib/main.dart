import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceControl(),
    );
  }
}

class VoiceControl extends StatefulWidget {
  @override
  _VoiceControlState createState() => _VoiceControlState();
}

class _VoiceControlState extends State<VoiceControl> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  String serverUrl =
      'http://192.168.178.125:5001/command'; // Update with your server URL

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    await _speech.initialize();
    _isListening = true;
    setState(() {});

    _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
        if (result.hasConfidenceRating && result.confidence > 0.5) {
          _sendCommandToServer(_text);
          _stopListening();
        }
      },
    );
  }

  void _stopListening() async {
    _isListening = false;
    await _speech.stop();
    setState(() {});
  }

  void _sendCommandToServer(String command) async {
    var response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'command': command}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['action'] == 'open_app' && data['url'] != null) {
        _openApp(data['url']);
      } else {
        print('Unknown action or no URL provided');
      }
    } else {
      print('Failed to send command to server: ${response.statusCode}');
    }
  }

  void _openApp(String packageName) async {
    // Using a dynamic method to open the app
    final intent = 'intent://$packageName#Intent;scheme=package;end';
    await http.get(Uri.parse(intent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Control App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isListening ? 'Listening...' : 'Press the button and speak',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              _text,
              style: TextStyle(fontSize: 32),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.stop : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}
