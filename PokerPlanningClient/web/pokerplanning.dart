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
  querySelector("#loggedIn").classes.toggle("hidden", true);
}

void showGame() {
  querySelector("#game").classes.toggle("hidden", false);
  querySelector("#myCards")
    ..append(createCard("1"))
    ..append(createCard("2"))
    ..append(createCard("3"));

  querySelector("#revealOthersCards").onClick.listen(revealOthersCards);
}

void revealOthersCards(_) {
  ws.send(JSON.encode({"revealAll": ""}));

}

void selectCard(Event e) {
  Element card = e.target;
  querySelectorAll(".card").forEach((c) => c.classes.toggle("selected", false));
  card.classes.toggle("selected");
  ws.send(JSON.encode({"cardSelection": [myName, card.id]}));
}

DivElement createCard(String value) {
  return new DivElement()
    ..setAttribute("id", value)
    ..setInnerHtml(value)
    ..classes.add("card")
    ..onClick.listen(selectCard);
}

void login(MouseEvent e) {
  InputElement nameInput = querySelector("#nameInput");
  myName = nameInput.value;

  if (myName.isEmpty) return;

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

  ws.onMessage.listen((MessageEvent e) => handleMessage(e.data));
}

void handleMessage(data) {
  print(data);

  var decoded = JSON.decode(data);
  Map game = decoded["game"];
  Map revealedGame = decoded["revealedGame"];

  if (game != null) {
    displayCards(game, false);
  } if(revealedGame != null) {
    displayCards(revealedGame, true);
  }
}

void displayCards(Map game, bool revealed) {
  print("display cards with revealed : $revealed");

  var othersCardDiv = querySelector("#othersCards");
  othersCardDiv.innerHtml = '';

  game.forEach((player, card) {
    DivElement cardDiv = new DivElement();
    cardDiv.id = player;

    if (revealed) {
      cardDiv.innerHtml = "$player : $card";
    } else {
      cardDiv.innerHtml = "$player : ?";
    }

    othersCardDiv.append(cardDiv);
  });
}
