import 'dart:async';

import'package:flutter/material.dart';

class MySetup extends StatefulWidget {
  const MySetup({super.key});

  @override
  State<MySetup> createState() => _MySetupState();
}

class _MySetupState extends State<MySetup> {

  bool darkMode = false;
  bool isPaused = true;
  bool resetConf = false;

  Color light_darker = Color.fromRGBO(55, 5, 65, 1);
  Color light = Color.fromRGBO(75, 25, 65, 1);
  Color light_ofset = Color.fromRGBO(95, 45, 85, 1);
  Color white = Color.fromRGBO(255,255,255,1);

  int timeRemaining = 3 * 60 * 60;
  DateTime? endTime;
  Timer? countDownTimer;
  Timer? resetConfTimer;

  void cancelResetTimer() {
    resetConfTimer?.cancel();
    resetConfTimer = null;

    if(resetConf) {
      setState(() { resetConf = false;});
    }
  }

  void resetTimer() {
    if(!resetConf) {
      setState(() { resetConf = true;});
      resetConfTimer = Timer(
        const Duration(seconds: 10),
            () {
          setState(() {
            resetConf = false;
            resetConfTimer = null;
          });
        },
      );
      return;
    }

    resetConfTimer?.cancel();
    resetConfTimer = null;
    countDownTimer?.cancel();
    countDownTimer = null;
    setState(() {timeRemaining = 3 * 60 * 60; isPaused = true; resetConf = false; endTime = null;});
  }

  void pauseTimer() {
    if (endTime != null) { final seconds = endTime!.difference(DateTime.now()).inSeconds;
      setState(() { timeRemaining = seconds.clamp(0, 3 * 60 * 60);});
      isPaused = true;
    } else {
      setState(() {
        isPaused = true;
      });
    }

    countDownTimer?.cancel();
    countDownTimer = null;
    endTime = null;
  }

  void resumeTimer() {
    if (timeRemaining == 0) { return; }
    startTimer();
  }

  void startTimer() {
    if(countDownTimer != null || timeRemaining == 0) {
      return;
    }

    endTime = DateTime.now().add(Duration(seconds: timeRemaining));

    isPaused = false;

    countDownTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateCountdown());
  }

  void updateCountdown() {
    if (endTime == null) { return; }

    final seconds = endTime!.difference(DateTime.now()).inSeconds;

    setState(() {timeRemaining = seconds.clamp(0, 3 * 60 * 60);});

    if (timeRemaining <= 0) {
      countDownTimer?.cancel();
      countDownTimer = null;
      endTime = null;
    }
  }

  String getCurrentPhase() {
    int elapsedTime = (3 * 60 * 60) - timeRemaining;
    final elapsedMinutes = elapsedTime ~/ 60;

    if (timeRemaining == (3 * 60 * 60)) {
      return '';
    } else if (elapsedMinutes <= 15) {
        return 'Setup and Deployment';
    } else if (elapsedMinutes <= 40) {
      return 'Turn 1';
    } else if (elapsedMinutes <= 65) {
      return 'Turn 2';
    } else if (elapsedMinutes <= 90) {
      return 'Turn 3';
    } else if (elapsedMinutes <= 115) {
      return 'Turn 4';
    } else if (elapsedMinutes <= 140) {
      return 'Turn 5';
    } else if (elapsedMinutes <= 165) {
      return 'Turn 6';
    } else {
      return 'Final 15 minutes';
    }
  }

  String formatTime(int seconds) {
    final hours = seconds ~/3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2,'0')}:'
        '${minutes.toString().padLeft(2,'0')}:'
        '${secs.toString().padLeft(2,'0')}';
  }

  @override
  void dispose() {
    countDownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? light_darker : white,

      body: Center(child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text(
                formatTime(timeRemaining),
                style: TextStyle(fontSize: 172, color: darkMode ? white : light)),

            const SizedBox(height: 12),

            Text(
              getCurrentPhase(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: darkMode ? white : light_ofset,
              )
            ),

            const SizedBox(height: 48),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    onPressed: () => setState(() {darkMode = !darkMode;}),
                    label: Text("M O D E"),
                    icon: darkMode ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
                    iconAlignment: IconAlignment.end,
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: isPaused ? startTimer : pauseTimer,
                  label: isPaused ? Text("S T A R T") : Text("P A U S E"),
                  icon: isPaused ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
                  iconAlignment: IconAlignment.end,
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: resetTimer,
                  label: !resetConf ? Text("R E S E T") : Text(style: TextStyle(color: Colors.white),"R E S E T"),
                  style: !resetConf ? null : ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.reset_tv)
                )
              ]
            )
          ]
        )
      )
      )
    );
  }
}