import 'dart:async';
import 'package:flutter/material.dart';

class MySetup extends StatefulWidget {
  const MySetup({super.key});

  @override
  State<MySetup> createState() => _MySetupState();
}

class _MySetupState extends State<MySetup> {
  bool darkMode = false;
  bool isPaused = true;
  bool primeReset = false;

  Color purple_01 = Color.fromRGBO(55, 5, 45, 1);
  Color purple_02 = Color.fromRGBO(75, 25, 65, 1);
  Color purple_03 = Color.fromRGBO(95, 45, 85, 1);
  Color white_00 = Color.fromRGBO(255, 255, 255, 1);
  Color white_01 = Color.fromRGBO(215, 215, 215, 1);

  int timeRemaining = 3 * 60 * 60;
  DateTime? endTime;
  Timer? countDownTimer;
  Timer? resetConfTimer;

  //TIMER CONTROLS
  void startTimer() {
    if (countDownTimer != null || timeRemaining == 0) {
      return;
    }

    endTime = DateTime.now().add(Duration(seconds: timeRemaining));
    setState(() {isPaused = false;});

    updateCountdown();

    countDownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateCountdown(),
    );
  }

  void pauseTimer() {
    if (endTime != null) {
      final seconds = endTime!.difference(DateTime.now()).inSeconds;
      setState(() {
        timeRemaining = seconds.clamp(0, 3 * 60 * 60);
      });
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
    if (timeRemaining == 0) {
      return;
    }
    startTimer();
  }

  void cancelResetTimer() {
    resetConfTimer?.cancel();
    resetConfTimer = null;

    if (primeReset) {
      setState(() {
        primeReset = false;
      });
    }
  }

  void resetTimer() {
    if (!primeReset) {
      setState(() {
        primeReset = true;
      });
      resetConfTimer = Timer(const Duration(seconds: 10), () {
        setState(() {
          primeReset = false;
          resetConfTimer = null;
        });
      });
      return;
    }

    resetConfTimer?.cancel();
    resetConfTimer = null;
    countDownTimer?.cancel();
    countDownTimer = null;
    setState(() {
      timeRemaining = 3 * 60 * 60;
      isPaused = true;
      primeReset = false;
      endTime = null;
    });
  }

  void updateCountdown() {
    if (endTime == null) {
      return;
    }

    final seconds = endTime!.difference(DateTime.now()).inSeconds;
    setState(() {
      timeRemaining = seconds.clamp(0, 3 * 60 * 60);
    });

    if (timeRemaining <= 0) {
      countDownTimer?.cancel();
      countDownTimer = null;
      endTime = null;
      isPaused = true;
    }
  }

  String getCurrentPhase() {
    int elapsedTime = (3 * 60 * 60) - timeRemaining;
    final elapsedMinutes = elapsedTime ~/ 60;

    if (timeRemaining == (3 * 60 * 60)) {
      return '';
    } else if (elapsedMinutes < 15) {
      return 'Setup and Deployment';
    } else if (elapsedMinutes < 40) {
      return 'Turn 1';
    } else if (elapsedMinutes < 65) {
      return 'Turn 2';
    } else if (elapsedMinutes < 90) {
      return 'Turn 3';
    } else if (elapsedMinutes < 115) {
      return 'Turn 4';
    } else if (elapsedMinutes < 140) {
      return 'Turn 5';
    } else if (elapsedMinutes < 165) {
      return 'Turn 6';
    } else if (elapsedMinutes < 180) {
      return 'Final 15 minutes!';
    } else {
      return 'Time!';
    }
  }

  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    countDownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? purple_01 : white_00,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            final timerFontSize = isMobile ? 48.0 : 88.0;
            final phaseFontSize = isMobile ? 22.0 : 32.0;
            final buttonFontSize = isMobile ? 14.0 : 17.0;
            final buttonHeight = isMobile ? 38.0 : 56.0;
            final padding = isMobile ? 16.0 : 32.0;

            return Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formatTime(timeRemaining),
                        style: TextStyle(
                          fontSize: timerFontSize,
                          color: darkMode ? white_00 : purple_02,
                        ),
                      ),

                      SizedBox(height: isMobile ? 20 : 32),

                      Text(
                        getCurrentPhase(),
                        style: TextStyle(
                          fontSize: phaseFontSize,
                          fontWeight: FontWeight.bold,
                          color: darkMode ? white_00 : purple_03,
                        ),
                      ),

                      SizedBox(height: isMobile ? 28 : 40),

                      if (isMobile) ...[
                        SizedBox(
                          height: buttonHeight,
                          width: 140,
                          child: ElevatedButton.icon(
                            onPressed: isPaused ? startTimer : pauseTimer,
                            label: Text(
                              isPaused ? "S T A R T" : "P A U S E",
                              style: TextStyle(fontSize: buttonFontSize),

                            ),
                            icon: isPaused
                                ? const Icon(Icons.play_arrow)
                                : const Icon(Icons.pause),
                            iconAlignment: IconAlignment.end,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: buttonHeight,
                          width: 140,
                          child: ElevatedButton.icon(
                            onPressed: resetTimer,
                            label: !primeReset
                                ? Text("R E S E T")
                                : Text(
                              style: TextStyle(color: Colors.white),
                              "R E S E T",
                            ),
                            style: !primeReset
                                ? null
                                : ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.reset_tv),
                          ),
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => setState(() {
                                darkMode = !darkMode;
                              }),
                              label: Text("M O D E"),
                              icon: darkMode
                                  ? const Icon(Icons.light_mode)
                                  : const Icon(Icons.dark_mode),
                              iconAlignment: IconAlignment.end,
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton.icon(
                              onPressed: isPaused ? startTimer : pauseTimer,
                              label: isPaused
                                  ? Text("S T A R T")
                                  : Text("P A U S E"),
                              icon: isPaused
                                  ? const Icon(Icons.play_arrow)
                                  : const Icon(Icons.pause),
                              iconAlignment: IconAlignment.end,
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton.icon(
                              onPressed: resetTimer,
                              label: !primeReset
                                  ? Text("R E S E T")
                                  : Text(
                                      style: TextStyle(color: Colors.white),
                                      "R E S E T",
                                    ),
                              style: !primeReset
                                  ? null
                                  : ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.reset_tv),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
