import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerTimerNotifier extends ChangeNotifier {
  Timer? _timer;
  Duration _duration = const Duration();

  Duration totalTime = const Duration(minutes: 1);
  String minutes = '';
  String seconds = '';

  bool isRunning = false;

  void startTimer() {
    isRunning = true;
    _duration = totalTime;

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final _seconds = _duration.inSeconds - 1;

      if (_seconds > -1) {
        _duration = Duration(seconds: _seconds);
        minutes = twoDigits(_duration.inMinutes.remainder(60));
        seconds = twoDigits(_duration.inSeconds.remainder(60));
        notifyListeners();
      } else {
        stopTimer();
      }
    });

    notifyListeners();
  }

  void stopTimer() {
    totalTime = _duration;
    _timer?.cancel();

    isRunning = false;
  }
}

final playerTimerProvider =
    ChangeNotifierProvider((_) => PlayerTimerNotifier());

class PlayerTimer extends ConsumerStatefulWidget {
  const PlayerTimer({Key? key}) : super(key: key);

  @override
  PlayerTimerState createState() => PlayerTimerState();
}

class PlayerTimerState extends ConsumerState<PlayerTimer> {
  void start() => ref.read(playerTimerProvider).startTimer();

  @override
  Widget build(BuildContext context) {
    final seconds = ref.watch(playerTimerProvider).seconds;
    final minutes = ref.watch(playerTimerProvider).minutes;

    return Column(
      children: [
        Text("$minutes:$seconds"),
        TextButton(
          onPressed: (() => ref.read(playerTimerProvider).startTimer()),
          child: const Text("Start"),
        ),
        TextButton(
          onPressed: (() => ref.read(playerTimerProvider).stopTimer()),
          child: const Text("Stop"),
        ),
      ],
    );
  }
}
