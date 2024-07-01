import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.lightGreen[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.green),
        ),
      ),
      home: const SpeechToTextScreen(),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key? key}) : super(key: key);

  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late bool _introductionWords;
  String _text = "";
  String _oldText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    initiliazeText();
  }

  void initiliazeText() {
    setState(() {
      _text = 'Press the button and start speaking';
      _oldText = '';
      _introductionWords = true;
    });
  }

  void _listen() async {
    setState(() {
      if (_introductionWords) {
        _text = '';
        _introductionWords = false;
      }
    });

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        finalTimeout: const Duration(seconds: 10),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          //pauseFor: const Duration(seconds: 1),
          //listenFor: const Duration(seconds: 10),
          onResult: (val) => setState(() {
            _text = '$_oldText ${_replacePunctuation(val.recognizedWords)}';
          }),
        );
      } else {
        setState(() => _isListening = false);
        _oldText = _text;
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _oldText = _text;
      _speech.stop();
    }
  }

  String _replacePunctuation(String text) {
    return text
        .replaceAll(' virgola', ',')
        .replaceAll(' punto', '.')
        .replaceAll(' punto esclamativo', '!')
        .replaceAll('. esclamativo', '!')
        .replaceAll(' punto interrogativo', '?')
        .replaceAll('. interrogativo', '?')
        .replaceAll(' due punti', ':')
        .replaceAll(' punto e virgola', ';');
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied in the notes')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voice to Text for your Diary',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: _copyToClipboard,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _text,
                        style: const TextStyle(
                            fontSize: 24.0, color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: initiliazeText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 17, vertical: 17),
                          textStyle: const TextStyle(fontSize: 10),
                        ),
                        child: const Icon(
                          Icons.highlight_remove,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _listen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 30),
                          textStyle: const TextStyle(fontSize: 24),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
