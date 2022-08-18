import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    ChessBoardController chessBoardController = ChessBoardController();

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
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text("Players info")),
          ],
        ),
      ),
    );
  }
}
