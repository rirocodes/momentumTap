import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'audio/audio_controller.dart';
import 'package:flutter_bounce/flutter_bounce.dart';

void main() async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
  WidgetsFlutterBinding.ensureInitialized();

  final audioController = AudioController();
  await audioController.initialize();

  runApp(MyApp(audioController: audioController));
}

class MyApp extends StatelessWidget {
  final AudioController audioController;

  const MyApp({required this.audioController, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum Tap',
      theme: ThemeData(
        textTheme: GoogleFonts.playTextTheme(),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 198, 136, 60)),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Momentum Tap', audioController: audioController),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.title, required this.audioController});

  final String title;
  final AudioController audioController;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    widget.audioController.playSound('assets/sounds/select.mp3');
    setState(() {
      _counter = _counter + 5;
    });
  }

  bool isMuted = true;

  void toggleMute() {
    if (widget.audioController.isMusicOn()) {
      widget.audioController.fadeOutMusic();
    } else {
      widget.audioController.startMusic();
    }
    setState(() {
      isMuted = !isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 155, 130, 92),
        // backgroundColor: Color.fromARGB(255, 158, 128, 84),
        // backgroundColor: Color.fromARGB(255, 158, 128, 84),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/images/paper.jpg'), // Path to your image
                fit: BoxFit.cover, // Adjust to fit the screen
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: toggleMute,
              child: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: const Color.fromARGB(255, 59, 59, 59),
                size: 30,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClickerBtn(onTap: _incrementCounter),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Click to collect rewards!\n (coming soon)',
                    style: GoogleFonts.play(
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(21.0),
                  child: Text(
                    'Score: $_counter',
                    style: GoogleFonts.play(
                        backgroundColor:
                            const Color.fromARGB(198, 255, 224, 132),
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: const Color.fromARGB(255, 59, 59, 59)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClickerBtn extends StatefulWidget {
  final VoidCallback onTap;

  const ClickerBtn({Key? key, required this.onTap}) : super(key: key);

  @override
  State<ClickerBtn> createState() => _ClickerBtnState();
}

class _ClickerBtnState extends State<ClickerBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // onTap: () => {widget.onTap()},
        child: Bounce(
      duration: Duration(milliseconds: 100),
      onPressed: () => {widget.onTap()},
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: Color.fromARGB(193, 247, 196, 44),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(179, 161, 161, 161),
              // color: Color.fromARGB(255, 247, 197, 44),
              blurRadius: 6,
              offset: const Offset(5, 8),
            ),
          ],
        ),
        // child: const Center(
        //   child: Text(
        //     'Click me',
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
      ),
    ));
  }
}
