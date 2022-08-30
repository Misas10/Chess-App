import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerTimerNotifier extends ChangeNotifier {
  late Duration remainingDuration;
  late String minutes;
  late String seconds;

  Timer? _timer;
  bool isRunning = false;

  // Show '0' as '00' or '1' as '01'
  // And two digits numbers stays the same
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Constructor method
  PlayerTimerNotifier({required Duration duration}) {
    remainingDuration = duration;
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
  }
}

final whiteTimerProvider = ChangeNotifierProvider(
    (_) => PlayerTimerNotifier(duration: const Duration(minutes: 3)));
final blackTimerProvider = ChangeNotifierProvider(
    (_) => PlayerTimerNotifier(duration: const Duration(minutes: 3)));

class PlayerTimer extends ConsumerStatefulWidget {
  final ChessBoardController chessBoardController;
  const PlayerTimer({Key? key, required this.chessBoardController})
      : super(key: key);

  @override
  PlayerTimerState createState() => PlayerTimerState();
}

class PlayerTimerState extends ConsumerState<PlayerTimer> {
  @override
  Widget build(BuildContext context) {
    // White pieces timer
    final remainingWhite = ref
        .watch(whiteTimerProvider)
        .remainingDuration
        .toString()
        .substring(2, 7);

    Future startWhiteTimer() => Future.delayed(
        Duration.zero, () => ref.read(whiteTimerProvider).startTimer());

    Future stopWhiteTimer() => Future.delayed(
        Duration.zero, () => ref.read(whiteTimerProvider).stopTimer());

    // Black pieces timer
    final remainingBlack = ref
        .watch(blackTimerProvider)
        .remainingDuration
        .toString()
        .substring(2, 7);

    Future startBlackTimer() => Future.delayed(
        Duration.zero, () => ref.read(blackTimerProvider).startTimer());

    Future stopBlackTimer() => Future.delayed(
        Duration.zero, () => ref.read(blackTimerProvider).stopTimer());

    return ValueListenableBuilder<Chess>(
      valueListenable: widget.chessBoardController,
      builder: ((context, value, child) {
        final bool isWhiteTurn = value.turn.name == "WHITE";

        final bool isBlackTurn = value.turn.name == "BLACK";

        if (isWhiteTurn) {
          startWhiteTimer();
          stopBlackTimer();
        }

        if (isBlackTurn) {
          startBlackTimer();
          stopWhiteTimer();
        }

        if (value.game_over) {
          stopBlackTimer();
          stopWhiteTimer();
        }

        return Column(children: [
          Text(remainingWhite),
          Text(remainingBlack),
        ]);
      }),
    );
  }
}
