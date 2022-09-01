import 'package:flutter/material.dart';
import 'package:chess_app/widgets/text_colors.dart';

// It may have some conflict with the Color class on Material package
// Thus the 'as' keyword
import 'package:flutter_chess_board/flutter_chess_board.dart' as chess_board;

Widget clockStyle(String timerText, chess_board.Color pieceColor,
    {required chess_board.ChessBoardController chessBoardController}) {
  const white = chess_board.Color.WHITE;
  const black = chess_board.Color.BLACK;

  Color whiteClockBg = clockInactiveBg;
  Color whiteTextColor = whiteClockInactiveText;

  Color blackClockBg = clockInactiveBg;
  Color blackTextColor = blackClockInactiveText;

  if (chessBoardController.game.turn == white) {
    whiteClockBg = whiteClockActiveBg;
    whiteTextColor = whiteClockActiveText;
  }

  if (chessBoardController.game.turn == black) {
    blackClockBg = blackClockActiveBg;
    blackTextColor = blackClockActiveText;
  }

  if (pieceColor == white) {
    return _clockBox(timerText,
        backgroundColor: whiteClockBg, textColor: whiteTextColor);
    //
  } else if (pieceColor == black) {
    return _clockBox(timerText,
        backgroundColor: blackClockBg, textColor: blackTextColor);
    //
  } else {
    throw ("Algo de errado não está certo");
  }
}

Container _clockBox(String timerText,
    {required Color backgroundColor, Color? textColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: backgroundColor,
    ),
    child: Text(
      timerText,
      style: TextStyle(
        // fontWeight: FontWeight.bold,
        fontFamily: "Roboto",
        fontSize: 24,
        color: textColor,
      ),
    ),
  );
}
