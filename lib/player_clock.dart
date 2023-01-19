import 'dart:async';
import 'package:chess_app/widgets/timer_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerTimerNotifier extends ChangeNotifier {
  late Duration remainingDuration;
  final Duration totalDuration;
  late String minutes;
  late String seconds;

  Timer? _timer;
  bool isRunning = false;

  // Show '0' as '00' or '1' as '01'
  // And two digits numbers stays the same
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Constructor method
  PlayerTimerNotifier({required this.totalDuration}) {
    remainingDuration = totalDuration;
    minutes = _twoDigits(remainingDuration.inMinutes.remainder(60));
    seconds = _twoDigits(remainingDuration.inSeconds.remainder(60));
  }

  void startTimer() {
    if (!isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final _seconds = remainingDuration.inSeconds - 1;

        if (_seconds > -1) {
          remainingDuration = Duration(seconds: _seconds);
          minutes = _twoDigits(remainingDuration.inMinutes.remainder(60));
          seconds = _twoDigits(remainingDuration.inSeconds.remainder(60));
          notifyListeners();
        } else {
          stopTimer();
        }
      });
      isRunning = true;
    }

    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();

    isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    remainingDuration = totalDuration;
  }
}

class Clock {
  final ChessBoardController chessBoardController;
  final ChangeNotifierProvider<PlayerTimerNotifier> provider;
  final WidgetRef ref;
  final Color piecesColor;

  Clock(this.ref,
      {required this.provider,
      required this.piecesColor,
      required this.chessBoardController});

  String get remaining =>
      ref.watch(provider).remainingDuration.toString().substring(2, 7);

  bool get isRunning => ref.watch(provider).isRunning;

  Future start() =>
      Future.delayed(Duration.zero, () => ref.read(provider).startTimer());

  Future stop() =>
      Future.delayed(Duration.zero, () => ref.read(provider).stopTimer());

  reset() => ref.read(provider).resetTimer();
  Widget show() {
    return clockStyle(remaining, piecesColor,
        chessBoardController: chessBoardController);
  }
}
