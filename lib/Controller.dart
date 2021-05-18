/// Author: Steven Ibarra
/// CS 3360 Dr. Cheon
/// Project 2 Dart Omak Game
import 'dart:io';

import 'ConsoleUI.dart';
import 'WebClient.dart';
import 'dart:core';

/// Class Controller. Performs interactions on the data model objects.
class Controller{
  /// Field/Variable to initialize the the user interface.
  var userInterphase;
  /// Field/Variable to initialize client requests methods to the server
  var client;
  /// Player 1: Person Player.
  var player;
  /// Player 2: Server/Computer Player.
  var server;
  /// Player 3: Dummy player. Just to fill the empty spaces, no participation.
  var empty;
  /// Field/Variable to initialize the board to be used.
  var board;

  /// Constructor, assignment to members.
  Controller()
      : userInterphase = ConsoleUI(),
        player = Player('\u001B[1;34mX\u001B[0m'),
        server = Player('\u001B[1;31mO\u001B[0m'),
        empty  = Player('.');
  /// Function run. Runs the CL App.
  Future <void> run() async{

    userInterphase.showMessage('Welcome to Omok Game');
    var url = userInterphase.promptServer(WebClient.DEFAULT);
    userInterphase.showMessage('Obtaining server information....');
    client = WebClient(url);
    var result = await client.getInfo(); // Get game's information
    if (result.isError) {
      userInterphase.showMessage(result.error);
      return;
    }
    var info = result.value;
    var strategy = userInterphase.promptStrategy(info.strategies);
    userInterphase.showMessage('Creating new game....');
    userInterphase.showMessage('Player 1 [Player]: X  Player 2 [Player]: O');
    var resultGame = await client.createGame(strategy);
    if (resultGame.isError){
      userInterphase.showMessage(result.error);
      return;
    }
    var pid = resultGame.value;
    board = Board(info.size, info.size, empty); // Initialize the board
    userInterphase.setBoard(board);
    await play(pid);
  }
  /// Future function to play the game.
  Future <void> play(var pid) async {
    var lastMove;
    while (true) {
      userInterphase.showBoard(lastMove);
      var coordinate = userInterphase.promptMove(); // Player's move
      var response = await client.playGame(pid, coordinate);
      if (response.isError){
        userInterphase.showMessage(response.error);
        break;
      }
      var move = response.value;
      board.stone(coordinate, player); // Place players stone
      if (move.player.isWin) {
        board.setWinRow(move.player.winRow);
        userInterphase.showBoard(lastMove, true);
        userInterphase.showMessage('You won!');
        break;
      }
      lastMove = [move.server.coorx,move.server.coory];
      board.stone(lastMove, server); // Server places stone
      if (move.server.isWin) {
        board.setWinRow(move.server.winRow);
        userInterphase.showBoard(lastMove, true);
        userInterphase.showMessage('You lose!');
        break;
      }
      if (move.server.isDraw) {
        userInterphase.showBoard(lastMove, true);
        userInterphase.showMessage('Boring!');
        break;
      }
    }
  }

}//End of class controller

///Class Board. Responsible for managing the data of the application
class Board {

  var winner, width, height, empty, places;
  /// Constructor
  Board(width, height, Player emptyPlace)
      : width = width,
        height = height,
        empty = emptyPlace,
        places = List.generate(width, (index) =>
            List.generate(height, (index) => (emptyPlace))),
        winner = Player('\u001B[1;33mW\u001B[0m');

  /// Function row() returns a complete row of the board
  void row(var i) => places = [i];
  /// Function rows() returns the entire rows of the board
  void rows() => places;
  /// Function isAvailable() checks if is an open slot
  bool isAvailable(List coordinate) => places[coordinate[0]][coordinate[1]] == empty;

  /// Function setWinRow() to set the winner row of the game
  void setWinRow(var row) {
    print('$row');
    for (var i = 0; i < row.length; i = i + 2) {
      places[row[i + 1]][row[i]] = winner;
    }
  }
  /// Function stone() places stone on available space
  void stone(var coordinate, Player player) {
      if (places[coordinate[1]][coordinate[0]] == empty) { //Check if the space is available
        places[coordinate[1]][coordinate[0]] = player;
        return;
      }
  }
}//End of class Board

/// Class Player. This class represent the player object
class Player {
  var piece;
  /// Constructor, with syntactic sugar for assignment to members.
  Player(this.piece);

  ///Function __toString() an override function to represent the object
  @override
  String toString() => piece;
}//End of class Player

