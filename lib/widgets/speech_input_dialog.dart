import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechInputDialog extends StatefulWidget {
  final stt.SpeechToText speech;

  const SpeechInputDialog(this.speech, {super.key});

  @override
  _SpeechInputDialogState createState() => _SpeechInputDialogState();
}

class _SpeechInputDialogState extends State<SpeechInputDialog> {
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await widget.speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'listening') {
          setState(() => _isListening = true);
        } else if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        setState(() => _isListening = false);
      },
    );

    if (!available) {
      setState(() {
        _recognizedText = 'Speech recognition not available.';
      });
    }
  }

  void _startListening() async {
    if (!_isListening) {
      debugPrint('Starting speech recognition...');
      await widget.speech.listen(
        onResult: (val) => setState(() {
          _recognizedText = val.recognizedWords;
        }),
        localeId: "ko_KR",
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      debugPrint('Stopping speech recognition...');
      await widget.speech.stop();
    }
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Voice Input', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recognizedText.isEmpty ? 'Speak to record your memo...' : _recognizedText,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isListening ? 'Stop' : 'Start'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_recognizedText);
          },
          child: Text('Save', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
