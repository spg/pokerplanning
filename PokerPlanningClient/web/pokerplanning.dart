import 'dart:html';
import 'dart:async';
import 'dart:convert';

Map<String, String> players = {
};
String myName;
WebSocket ws;

void main() {
  querySelector("#loginButton").onClick.listen(login);
  initWebSocket();
}

void hideLoginForm() {
  querySelector("#login").remove();
}

void showLoginSuccessful() {
  querySelector("#nameSpan").text = myName;
  querySelector("#loggedIn").classes.toggle("hidden");
}

void showGame() {
  querySelector("#game").classes.toggle("hidden");
}

void login(MouseEvent e) {
  InputElement nameInput = querySelector("#nameInput");
  myName = nameInput.value;

  if (myName.isEmpty) return;

  var loginInfo = {'login' : myName};

  ws.send(JSON.encode(loginInfo));

  hideLoginForm();
  showLoginSuccessful();
  showGame();
}

outputMsg(String msg) {
  print(msg);
}

void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;

  outputMsg("Connecting to websocket");
  ws = new WebSocket('ws://127.0.0.1:4040/ws');

  ws.onOpen.listen((e) {
    outputMsg('Connected');
  });

  ws.onClose.listen((e) {
    outputMsg('Websocket closed, retrying in $retrySeconds seconds');
  });

  ws.onError.listen((e) {
    outputMsg("Error connecting to ws");
  });

  ws.onMessage.listen((MessageEvent e) {
    outputMsg('Received message: ${e.data}');
  });
}