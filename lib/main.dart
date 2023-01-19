import 'player_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_app/widgets/text_colors.dart';

void main() {
  runApp(const ProviderScope(child: ChessApp()));
}

final whiteClockProvider = ChangeNotifierProvider(
    (_) => PlayerTimerNotifier(totalDuration: const Duration(minutes: 5)));

final blackClockProvider = ChangeNotifierProvider(
    (_) => PlayerTimerNotifier(totalDuration: const Duration(minutes: 5)));

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

class MyHomePageState extends ConsumerState<MyHomePage>
    with TickerProviderStateMixin {
  late ChessBoardController chessBoardController;
  // List of moves made during the game
  List<String?> sanList = [''];
  bool gameIsPaused = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    chessBoardController = ChessBoardController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void dispose() {
    super.dispose();
    chessBoardController.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sanList = chessBoardController.getSan();

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
        backgroundColor: appBarBg,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10, left: 4, right: 4),
              // Creates a scrollable horizontal list
              child: SingleChildScrollView(
                // Scrolls automatically when a new item is added
                reverse: true,
                scrollDirection: Axis.horizontal,
                // Shows a text of moves that were made
                child: RichText(
                  text: sanList.isNotEmpty
                      ? TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: sanList.take(sanList.length - 1).join(" "),
                              style: const TextStyle(color: labelText)),
                          TextSpan(
                              text: '  ${sanList.last}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ])
                      : const TextSpan(text: ""),
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
    bool enableUserMoves =
        whiteClock.remaining != "00:00" || blackClock.remaining != "00:00";

    if (!gameIsPaused) {
      if (chessBoardController.value.turn == Color.WHITE) {
        whiteClock.start();
        blackClock.stop();
      }

      if (chessBoardController.value.turn == Color.BLACK) {
        blackClock.start();
        whiteClock.stop();
      }
    } else {
      enableUserMoves = false;
    }

    return Column(
      children: [
        _infoRow("Black", blackClock.show()),
        ChessBoard(
          size: MediaQuery.of(context).size.width,
          controller: chessBoardController,
          enableUserMoves: enableUserMoves,
        ),
        _infoRow("White", whiteClock.show()),
        _buildButtons(whiteClock: whiteClock, blackClock: blackClock),
      ],
    );
  }

  Padding _infoRow(String playerName, Widget showClock) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
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

  Widget _buildButtons({required Clock whiteClock, required Clock blackClock}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        resetButton(whiteClock, blackClock),
        playPauseButton(whiteClock, blackClock),
      ],
    );
  }

  IconButton playPauseButton(Clock whiteClock, Clock blackClock) {
    return IconButton(
      onPressed: () {
        if (!gameIsPaused) {
          whiteClock.stop();
          blackClock.stop();
          debugPrint("Game is paused");
        } else {
          whiteClock.start();
          blackClock.start();
          debugPrint("Game as continued");
        }
        gameIsPaused = !gameIsPaused;

        // Change the icon
        gameIsPaused
            // Pause icon
            ? _animationController.forward()
            // Play icon
            : _animationController.reverse();
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _animationController,
      ),
    );
  }

  IconButton resetButton(Clock whiteClock, Clock blackClock) {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Restart game?"),
              content: const Text("This will restart the game and the timer."),
              actions: [
                TextButton(onPressed: () {}, child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      whiteClock.reset();
                      blackClock.reset();
                      chessBoardController.resetBoard();
                    },
                    child: const Text("Yes"))
              ],
            ),
          );
        },
        icon: const Icon(Icons.refresh));
  }
}
