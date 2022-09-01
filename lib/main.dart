import 'package:chess_app/player_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_app/widgets/text_colors.dart';

void main() {
  runApp(const ProviderScope(child: ChessApp()));
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: 'Chess App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColorDark: primaryColor,
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

final whiteClockProvider = ChangeNotifierProvider(
    (_) => PlayerTimerNotifier(duration: const Duration(minutes: 5)));

final blackClockProvider = ChangeNotifierProvider(
    (_) => PlayerTimerNotifier(duration: const Duration(minutes: 5)));

class MyHomePageState extends ConsumerState<MyHomePage> {
  late ChessBoardController chessBoardController;

  @override
  void initState() {
    super.initState();
    chessBoardController = ChessBoardController();
  }

  @override
  void dispose() {
    super.dispose();
    chessBoardController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // White Clock Provider
    Clock whiteClock = Clock(ref,
        provider: whiteClockProvider,
        piecesColor: Color.WHITE,
        chessBoardController: chessBoardController);

    // Black Clock Provider
    Clock blackClock = Clock(ref,
        provider: blackClockProvider,
        piecesColor: Color.BLACK,
        chessBoardController: chessBoardController);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: labelText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBg,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: 10, bottom: MediaQuery.of(context).size.height / 32),
              // Creates a scrollable horizontal list
              child: SingleChildScrollView(
                // Scrolls automatically when a new item is added
                reverse: true,
                scrollDirection: Axis.horizontal,
                // Listens to a value and updates it with the builder
                // In this case, values stored in the chessBoardController variable
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
            _buildChessBoard(whiteClock: whiteClock, blackClock: blackClock),
          ],
        ),
      ),
    );
  }

  Widget _buildChessBoard(
      {required Clock whiteClock, required Clock blackClock}) {
    if (chessBoardController.value.turn == Color.WHITE) {
      whiteClock.start();
      blackClock.stop();
    }

    if (chessBoardController.value.turn == Color.BLACK) {
      blackClock.start();
      whiteClock.stop();
    }
    return Column(
      children: [
        _infoRow("Black", blackClock.show()),
        ChessBoard(
          controller: chessBoardController,
        ),
        _infoRow("White", whiteClock.show()),
      ],
    );
  }

  Padding _infoRow(String playerName, Widget showClock) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            playerName,
            style: const TextStyle(
              fontFamily: "Roboto Mono",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: labelText,
            ),
          ),
          showClock,
        ],
      ),
    );
  }
}
