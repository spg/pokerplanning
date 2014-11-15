import 'dart:io';
import 'dart:convert';

WebSocket ws;
Map<String, String> game = {
};

printGame() {
  print("The players connected are : ");
  game.forEach((k, v) => print("$k and their current card choice is: $v"));
}

void handleMessage(socket, message) {
  print("Received : " + message);

  Map json = JSON.decode(message);

  var login = json["login"];

  if (login != null) {
    game.putIfAbsent(login, () => "");
    socket.add("$login successfully connected");
  }

  printGame();
}

void main() {
  HttpServer.bind('127.0.0.1', 4040).then((server) {
    server.listen((HttpRequest req) {
      if (req.uri.path == '/ws') {
        WebSocketTransformer.upgrade(req)
          ..then((socket) => socket.listen((msg) => handleMessage(socket, msg)));
      }
    }).onError((e) => print("An error occurred."));
  });
}

