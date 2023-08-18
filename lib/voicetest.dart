import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Music Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: Voice());
  }
}

class Voice extends StatefulWidget {
  Voice({super.key});

  @override
  State<Voice> createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  //late stt.SpeechToText _speech;
  SpeechToText speech = SpeechToText();
  bool _isListening = false;
  String _textSpeech = 'Speak English';

  var _speech = stt.SpeechToText();

  void onListen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'));
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
            onResult: (val) => setState(() {
                  _textSpeech = val.recognizedWords;
                }));
      }
    } else {
      setState(() {
        _isListening = false;
        //_speech.stop();
      });
      _speech.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Speech To Text')),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text(
                      "Hold the button and start speaking",
                      textAlign: TextAlign.center,
                    ),
                    children: [
                      Container(
                        child: IconButton(
                          icon: _isListening
                              ? Icon(Icons.mic)
                              : Icon(Icons.mic_none),
                          onPressed: () {
                            onListen();
                          },
                        ),
                      ),
                      Container(
                        child: Text(
                          _textSpeech,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  );
                });

            // onListen();
          },
          child: Icon(Icons.mic),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Text(_textSpeech),
        ));

    // return SimpleDialog(
    //   title: const Text(
    //     "Hold the button and start speaking",
    //     textAlign: TextAlign.center,
    //   ),
    //   children: [
    //     Container(
    //       child: IconButton(
    //         icon: Icon(Icons.mic),
    //         onPressed: () {},
    //       ),
    //     )
    //   ],
    // );
  }
}
