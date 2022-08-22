import 'dart:async';

import 'package:chess_app/players_timers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerTimerProvider =
    ChangeNotifierProvider(((_) => PlayerTimerNotifier()));

void main() {
  runApp(const ProviderScope(child: ChessApp()));
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Chess App'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    ChessBoardController chessBoardController = ChessBoardController();
    final seconds = ref.watch(playerTimerProvider).seconds;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: 10, bottom: MediaQuery.of(context).size.height / 32),
              // Creates a scrollable list
              child: SingleChildScrollView(
                // Scrolls automatically when a new item is added
                reverse: true,
                scrollDirection: Axis.horizontal,
                // Listens to a value and updates it with the builder
                // In this case values stored in the chessBoardController variable
                child: ValueListenableBuilder<Chess>(
                  valueListenable: chessBoardController,
                  builder: ((context, value, child) => Text(chessBoardController
                      .getSan()
                      .fold(
                          '',
                          (previousValue, element) =>
                              '$previousValue ${element ?? ''}'))),
                ),
              ),
            ),
            ChessBoard(
              controller: chessBoardController,
            ),
            const PlayerTimer(),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration d) {
    String f(int n) {
      return n.toString().padLeft(2, '0');
    }

    // We want to round up the remaining time to the nearest second
    d += const Duration(microseconds: 999999);
    return "${f(d.inMinutes)}:${f(d.inSeconds % 60)}";
  }
}
