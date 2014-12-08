import 'dart:html';
import 'dart:convert';
import 'card.dart';
import 'card_component.dart';

import 'package:dart_config/default_browser.dart';
import 'package:polymer/polymer.dart';

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
  initPolymer();

  loadConfig()
  .then((Map config) {
    hostname = config["hostname"];
    port = config["port"];
  }).catchError((error) => print(error))
  .then((_) {
    if (hostname == null) throw("hostname wasn't set in config.yaml");
  }).catchError(showError)
  .then((_) {
    if (port == null) throw("port wasn't set in config.yaml");
  }).catchError(showError)
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
    ..innerHtml = "<div class=\"cardContainer\"><div class=\"card cardSpacer\"></div></div>"
    ..append(new Card.selectCard("0", selectCard).root)
    ..append(new Card.selectCard("½", selectCard).root)
    ..append(new Card.selectCard("1", selectCard).root)
    ..append(new Card.selectCard("2", selectCard).root)
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
  querySelector("#reset").onClick.listen(initReset);
}

void revealOthersCards(_) => sendSocketMsg({
    "revealAll": ""
});

void clearSelectedCard() => querySelectorAll(".card").forEach((Element c) => c.classes.toggle("selected", false));

void initReset(_) {
  sendSocketMsg({
      "resetRequest": ""
  });
}

void gameHasReset() {
  clearSelectedCard();
}

void selectCard(Event e) {
  Element card = e.target;
  clearSelectedCard();
  card.classes.toggle("selected");
  sendSocketMsg({
      "cardSelection": [myName, card.id]
  });
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

  sendSocketMsg(loginInfo);

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

void logout(String msg) {
  ws.close();
  window.alert(msg);
  localStorage.remove("username");
  window.location.reload();
}

void handleMessage(data) {
  print(data);

  var decoded = JSON.decode(data);
  Map game = decoded["game"];
  Map revealedGame = decoded["revealedGame"];
  String reset = decoded["gameHasReset"];
  Map kick = decoded["kick"];

  if (game != null) {
    displayCards(game, false);
  } else if (revealedGame != null) {
    displayCards(revealedGame, true);
  } else if (reset != null) {
    print("Game has reset!");
    gameHasReset();
  } else if (kick != null) {
    handleKick(kick);
  }
}

void displayCards(Map game, bool revealed) {
  print("display cards with revealed : $revealed");

  var othersCardDiv = querySelector("#othersCards")
    ..innerHtml = "";

  game.forEach((player, card) {
    CardComponent cardComponent = new CardComponent.revealCard(player, card, revealed, kickPlayer);
    othersCardDiv.append(cardComponent);
  });
}

void sendSocketMsg(Object jsObject) {
  ws.send(JSON.encode(jsObject));
}

void kickPlayer(String player) {
  sendSocketMsg({
      "kicked" : player
  });
}

void handleKick(Map kick) {
  String kicked = kick["kicked"];
  String kickedBy = kick["kickedBy"];

  if (kicked == myName) {
    var msg = "you have been kicked by: $kickedBy";
    logout(msg);
  } else {
    print("$kicked has been kicked by $kickedBy");
  }
}
