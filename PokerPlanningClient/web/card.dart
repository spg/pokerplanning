import 'dart:html';

class Card {
  String playerName;
  String value;

  DivElement root = new DivElement();
  DivElement _elem = new DivElement();
  DivElement _label = new DivElement();

  Card.revealCard(this.playerName, this.value) {
    root.append(_elem);
    root.append(_label);

    if (playerName.isNotEmpty) {
      _label.innerHtml =playerName;
    }
    _elem.innerHtml = value;

    _elem.setAttribute("id", playerName);
    _elem.classes.add("card");

    root.classes.add("cardContainer");
  }

  Card.selectCard(this.value, clickHandler) {
    root.append(_elem);

    _elem.innerHtml = value;

    _elem.onClick.listen(clickHandler);

    _elem.setAttribute("id", value);
    _elem.classes.add("card");

    root.classes.add("cardContainer");
  }
}
