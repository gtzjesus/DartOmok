import 'package:http/http.dart' as http;
import 'dart:convert';

/// Class Client. Implements all methods to connecting to the Web Service
class WebClient {
  /// Constants definition and initialization
  static const DEFAULT = 'http://www.cs.utep.edu/cheon/cs3360/project/omok/';
  static const INFO = '/info/';
  static const NEW = '/new/';
  static const PLAY = '/play/';
  static const STRATEGY = 'strategy';
  static const PID = 'pid';
  static const MOVE = 'move';

  /// Field/Variable to store the url of the Web Service to be used
  var url;

  /// Field/Variable to store the responses of the Web Service
  var resp;

  /// Constructor, with syntactic sugar for assignment to members.
  WebClient(this.url) : resp = ResponseParser();

  /// Function getInfo(). Retrieves the info from the Web Service returns
  /// an object Result<Info>
  Future<Result<Info>> getInfo() async {
    try {
      var response = await http.get(url + INFO);
      var info = json.decode(response.body);
      return resp.parseInfo(info);
    } catch (e) {
      return Result.error('Server Connection failed');
    }
  }

  /// Function createGame retrieves information about the game from the
  /// Web Service and returns an object Result<String>
  Future<Result<String>> createGame(var strategy) async {
    try {
      var response = await http.get(url + NEW + '?' + STRATEGY + '=$strategy');
      var nuevo = json.decode(response.body);

      return resp.parseNew(nuevo);
    } catch (e) {
      return Result.error('Server Connection failed');
    }
  }

  /// Function playGame(). Retrieves information about the game from the Web
  /// Service and returns an object Result<Play>
  Future<Result<Play>> playGame(var pid, var coordinate) async {
    var crx = coordinate[0];
    var cry = coordinate[1];
    try {
      var response = await http
          .get(url + PLAY + '?' + PID + '=$pid&' + MOVE + '=$crx,$cry');
      var nuevo = json.decode(response.body);
      return resp.parsePlay(nuevo);
    } catch (e) {
      return Result.error('Server Connection failed');
    }
  }
} //End of WebClient class
/// Class ResponseParser. For parsing the information from the Web Service

class ResponseParser {
  /// Constants definition and initialization
  static const SIZE = 'size';
  static const STRATEGIES = 'strategies';
  static const RESPONSE = 'response';
  static const REASON = 'reason';
  static const PID = 'pid';
  static const ACK_MOVE = 'ack_move';
  static const MOVE = 'move';
  static const COORX = 'x';
  static const COORY = 'y';
  static const IS_WIN = 'isWin';
  static const IS_DRAW = 'isDraw';
  static const WIN_ROW = 'row';

  ResponseParser();

  /// Function parseInfo. Parsing the information /info/ from the Web Service.
  /// Use json_decode to decode the information
  Result<Info> parseInfo(var jsonString) {
    try {
      var strategies = jsonString[STRATEGIES];
      var size = jsonString[SIZE];
      var info = Info(size, strategies);
      return Result.value(info);
    } catch (ex) {
      return Result.error('Invalid JSON info');
    }
  }

  /// Function parseNew. Parsing the information /new/ from the Web Service.
  /// Use json_decode to decode the information
  Result<String> parseNew(var jsonString) {
    try {
      var response = jsonString[RESPONSE];
      if (response) {
        var pid = jsonString[PID];
        return Result.value(pid);
      }
      var reason = jsonString[REASON];
      return Result.error('Server: $reason');
    } catch (e) {
      return Result.error('Invalid JSON info');
    }
  }

  Result<Play> parsePlay(var jsonString) {
    try {
      var response = jsonString[RESPONSE];
      if (response) {
        var ack = parseMove(jsonString[ACK_MOVE]);
        var server = jsonString.containsKey(MOVE)
            ? parseMove(jsonString[MOVE])
            : parseMove(jsonString[ACK_MOVE]);
        var play = Play(ack, server);
        return Result.value(play);
      }
      var reason = jsonString[REASON];
      return Result.error('Server: $reason');
    } catch (e) {
      return Result.error('Invalid JSON info');
    }
  }

  /// Function parseMove(). Parsing the information Move from the Web Service
  Move parseMove(var move) {
    var coorx = move[COORX];
    var coory = move[COORY];
    var isWin = move[IS_WIN];
    var isDraw = move[IS_DRAW];
    var winRow = move[WIN_ROW];
    return Move(coorx, coory, isWin, isDraw, winRow);
  }
} //End of class

/// Class Info. To create the Info to store the information from the Web Service
class Info {
  var size, strategies;

  /// Constructor, with syntactic sugar for assignment to members.
  Info(this.size, this.strategies);
}

/// Class Result. Generates the outcome.
class Result<T> {
  final T value;
  final String error;

  Result(this.value, [this.error]);
  Result.value(T value) : this(value);
  Result.error(String error) : this(null, error);
  bool get isValue => value != null;
  bool get isError => error != null;
}

/// Class Move. Creates the move object
class Move {
  var coorx, coory, isWin, isDraw, winRow;

  Move(this.coorx, this.coory, this.isWin, this.isDraw, this.winRow);
}

/// Class Play. Creates player object
class Play {
  var player, server;

  /// Constructor, with syntactic sugar for assignment to members.
  Play(this.player, this.server);
}
