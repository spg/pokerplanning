import 'dart:io';
import 'dart:convert';

import 'package:dart_config/default_server.dart';

Map<String, String> game = {
};
var allConnections = [];
var hostname;
var port;

printGame() {
  print("The players connected are : ");
  game.forEach((k, v) => print("$k and their current card choice is: $v"));
}

void handleMessage(socket, message) {
  print("Received : " + message);

  Map json = JSON.decode(message);

  var login = json["login"];
  var cardSelection = json["cardSelection"];
  var reveal = json["revealAll"];
  var reset = json["reset"];

  if (login != null) {
    print("Adding $login to the logged in users");
    game.putIfAbsent(login, () => "");
    broadcastGame(false);
  } else if (cardSelection != null) {
    var playerName = cardSelection[0];
    var selectedCard = cardSelection[1];
    print("Adding $playerName card selection: $selectedCard.");
    game[playerName] = selectedCard;
  } else if (reveal != null) {
    broadcastGame(true);
  } else if (reset != null) {
    game.forEach((player, _) => game[player] = "");
    broadcastGame(false);
  }

  printGame();
}

void broadcastGame(bool reveal) {
  var encodedGame = {
      (reveal ? "revealedGame" : "game"): game
  };

  allConnections.forEach((s) => s.add(JSON.encode(encodedGame)));
}

void startSocket() {
  HttpServer.bind(hostname, port).then((server) {
    server.listen((HttpRequest req) {
      if (req.uri.path == '/ws') {
        WebSocketTransformer.upgrade(req)
          ..then((socket) => allConnections.add(socket))
          ..then((socket) => socket.listen((msg) => handleMessage(socket, msg)));
      }
    })
      ..onError((e) => print("An error occurred."));
  });
}

void main() {
  loadConfig()
  .then((Map config) {
    hostname = config["hostname"];
    port = config["port"];
  }).catchError((error) => print(error))
  .then((_) {if (hostname == null) throw("hostname wasn't set in config.yaml");}).catchError(showError)
  .then((_) {if (port == null) throw("port wasn't set in config.yaml");}).catchError(showError)
  .then((_) => startSocket());
}

void showError(error) => print(error);

