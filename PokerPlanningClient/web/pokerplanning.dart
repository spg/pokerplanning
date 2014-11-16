import 'dart:html';
import 'dart:convert';
import 'card.dart';

import 'package:dart_config/default_browser.dart';

Map<String, String> players = {
};
Storage localStorage = window.localStorage;
WebSocket ws;
var hostname;
var port;

String get myName => localStorage['username'];

void set myName(String newName) {
  localStorage['username'] = newName;
}

void main() {
  loadConfig()
  .then((Map config) {
    hostname = config["hostname"];
    port = config["port"];
  }).catchError((error) => print(error))
  .then((_) {if (hostname == null) throw("hostname wasn't set in config.yaml");}).catchError(showError)
  .then((_) {if (port == null) throw("port wasn't set in config.yaml");}).catchError(showError)
  .then((_) => querySelector("#loginButton").onClick.listen(login)).catchError(showError)
  .then((_) => initWebSocket()).catchError(showError);
}

void showError(error) => querySelector("#error").appendHtml("$error.toString() <br>");

void hideLoginForm() {
  querySelector("#login").remove();
}

void showLoginSuccessful() {
  querySelector("#nameSpan").text = myName;
  querySelector("#loggedIn").classes.toggle("hidden", false);
}

void showGame() {
  querySelector("#game").classes.toggle("hidden", false);
  querySelector("#myCards")
    ..innerHtml = ""
    ..append(new Card.selectCard("0", selectCard).root)
    ..append(new Card.selectCard("½", selectCard).root)
    ..append(new Card.selectCard("1", selectCard).root)
    ..append(new Card.selectCard("3", selectCard).root)
    ..append(new Card.selectCard("5", selectCard).root)
    ..append(new Card.selectCard("8", selectCard).root)
    ..append(new Card.selectCard("13", selectCard).root)
    ..append(new Card.selectCard("20", selectCard).root)
    ..append(new Card.selectCard("40", selectCard).root)
    ..append(new Card.selectCard("∞", selectCard).root)
    ..append(new Card.selectCard("?", selectCard).root)
    ..append(new Card.selectCard("Pause", selectCard).root)
  ;

  querySelector("#revealOthersCards").onClick.listen(revealOthersCards);
  querySelector("#reset").onClick.listen(reset);
}

void revealOthersCards(_) => ws.send(JSON.encode({
    "revealAll": ""
}));

void reset(_) {
  showGame();
  ws.send(JSON.encode({
      "reset": ""
  }));
}

void selectCard(Event e) {
  Element card = e.target;
  querySelectorAll(".card :first-child").forEach((c) => c.classes.toggle("selected", false));
  card.classes.toggle("selected");
  ws.send(JSON.encode({
      "cardSelection": [myName, card.id]
  }));
}

void handleLoginClick(MouseEvent e) {
  InputElement nameInput = querySelector("#nameInput");
  String newName = nameInput.value;

  if (newName.isEmpty) return;

  myName = newName;

  onUserExists();
}

onUserExists() {
  var loginInfo = {
      'login' : myName
  };

  ws.send(JSON.encode(loginInfo));

  hideLoginForm();
  showLoginSuccessful();
  showGame();
}

outputMsg(String msg) {
  print(msg);
}

onSocketOpen(event) {
  outputMsg('Connected');

  if (myName == null) {
    querySelector("#loginButton").onClick.listen(handleLoginClick);
  } else {
    onUserExists();
  }
}

void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;

  outputMsg("Connecting to websocket");
  ws = new WebSocket('ws://$hostname:$port/ws');

  ws.onOpen.listen(onSocketOpen);

  ws.onClose.listen((e) {
    outputMsg('Websocket closed, retrying in $retrySeconds seconds');
  });

  ws.onError.listen((e) {
    outputMsg("Error connecting to ws");
  });

  ws.onMessage.listen((MessageEvent e) => handleMessage(e.data));
}

void handleMessage(data) {
  print(data);

  var decoded = JSON.decode(data);
  Map game = decoded["game"];
  Map revealedGame = decoded["revealedGame"];
  Map reset = decoded["reset"];

  if (game != null) {
    displayCards(game, false);
  } else if (revealedGame != null) {
    displayCards(revealedGame, true);
  } else if (reset != null) {

  }
}

void displayCards(Map game, bool revealed) {
  print("display cards with revealed : $revealed");

  var othersCardDiv = querySelector("#othersCards");
  othersCardDiv.innerHtml = '';

  game.forEach((player, card) {
    if (revealed) {
      othersCardDiv.append(new Card.revealCard(player, card).root);
    } else {
      othersCardDiv.append(new Card.revealCard(player, "...").root);
    }
  });
}
