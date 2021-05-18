import 'package:validators/validators.dart';
import 'dart:io';
import 'Controller.dart';

/// Class ConsoleUI. The presentation of the model.
class ConsoleUI {
  /// Variable for the board to be used
  var board;

  /// Function setBoard(). Sets the board to be used.
  void setBoard(Board board) => this.board = board;

  /// Function showMessage(). Util function to display a message
  void showMessage(String msg) => print(msg);

  /// Function showBoard(). Displays the board, keep track of the server last move
  void showBoard(var lastMove, [var winMove]) {
    var row;
    var counter = 1;
    var indexes =
        List<int>.generate(board.width, (i) => (i + 1) % 10).join(' ');
    stdout.writeln('x  $indexes');
    print('y  - - - - - - - - - - - - - - - ');
    row = board.rows();
    row.forEach((element) {
      print('$counter| ' + element.join(' ')); // Prints the board
      if (counter == 9) counter = -1;
      counter++;
    });
  }

  /// Function promptServer(). Prompts for the Web Service URL and gives a default one
  String promptServer(var defaultURL) {
    while (true) {
      stdout.write('Enter the Server URL[default: $defaultURL]: ');
      var url = stdin.readLineSync();
      if (url.isEmpty) url = defaultURL; //If empty use default URL
      if (isURL(url)) return url; //If the URL is valid return url, ends loop
      print('Invalid URL: $url');
    }
  }

  /// Function promptStrategy(). Prompts for the strategy to be used by the game
  String promptStrategy(var strategies) {
    while (true) {
      int selection;
      stdout.write(
          'Select the server strategy: 1. Smart 2. Random [default: 1]: ');
      var line = stdin.readLineSync();
      if (line.isEmpty) line = '1';
      try {
        selection = int.parse(line) - 1;
        if (selection < 0 || selection > 1) {
          print('Invalid selection: ${selection + 1} ');
          continue;
        }
        var strategy = strategies[selection];
        print('Selected strategy: $strategy');
        return strategy;
      } on FormatException {
        print('Invalid selection: $line');
      }
    }
  }

  /// Function promptMove(). Prompts for player move on the board
  List promptMove() {
    int x;
    int y;

    while (true) {
      stdout.write('Enter x: ');
      var userx = stdin.readLineSync();
      stdout.write('Enter y: ');

      var usery = stdin.readLineSync();
      if (userx.isEmpty || usery.isEmpty) continue;

      try {
        x = int.parse(userx);
        y = int.parse(usery);
        var array = [x - 1, y - 1];
        if (x >= 1 &&
            x <= 15 &&
            y >= 1 &&
            y <= 15 &&
            board.isAvailable(array)) {
          return array;
        }
        stdout.write('Invalid index\n');
      } on FormatException {
        stdout.write('Invalid index\n');
      }
    }
  }
} //End of class
