import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'card.dart';

Map<String, String> players = {
};
Storage localStorage = window.localStorage;
WebSocket ws;

void main() {
  initWebSocket();
}

void hideLoginForm() {
  querySelector("#login").remove();
}

void showLoginSuccessful() {
  querySelector("#nameSpan").text = getMyName();
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
      "cardSelection": [getMyName(), card.id]
  }));
}

void handleLoginClick(MouseEvent e) {
  InputElement nameInput = querySelector("#nameInput");
  String myName = nameInput.value;

  if (myName.isEmpty) return;

  setMyName(myName);

  onUserExists();
}

onUserExists() {
  var loginInfo = {
      'login' : getMyName()
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

  if (getMyName() == null) {
    querySelector("#loginButton").onClick.listen(handleLoginClick);
  } else {
    onUserExists();
  }
}

void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;

  outputMsg("Connecting to websocket");
  ws = new WebSocket('ws://127.0.0.1:4040/ws');

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

String getMyName() {
  return localStorage['username'];
}

setMyName(String myName) {
  localStorage['username'] = myName;
}
