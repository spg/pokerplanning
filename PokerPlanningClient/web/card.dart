import 'dart:html';

class Card {
  String playerName;
  String value;

  DivElement root = new DivElement();
  DivElement _elem = new DivElement();
  DivElement _label = new DivElement();
  ButtonElement _kickBtn = new ButtonElement();

  Card.revealCard(this.playerName, this.value, kickHandler) {
    root.append(_elem);
    root.append(_label);
    root.append(_kickBtn);

    if (playerName.isNotEmpty) {
      _label.innerHtml = "<h3>" + playerName + "</h3>";
    }
    _elem.innerHtml = value;

    _elem.setAttribute("id", playerName);
    _elem.classes.add("card");

    root.classes.add("cardContainer");

    _kickBtn.text = "Kick this player";
    _kickBtn.onClick.listen((e) => kickHandler(playerName));
  }

  Card.selectCard(this.value, clickHandler) {
    root.append(_elem);

    _elem.innerHtml = value;

    _elem.onClick.listen(clickHandler);

    _elem.setAttribute("id", value);
    _elem.classes.add("card");

    root.classes.add("cardContainer");
  }

  void setSelected(bool isSelected) {
    _elem.classes.toggle("selected", isSelected);
  }
}
