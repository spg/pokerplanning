library card_component;

import 'package:polymer/polymer.dart';
import 'dart:html' show Event, Node, CustomEvent;
import 'dart:html';

@CustomTag('card-component')
class CardComponent extends PolymerElement {
  @published
  String playerName;
  @published
  String valueToDisplay;
  @published
  bool revealed;

  String _value;
  var _kickHandler;
  ButtonElement _kickButton;
  DivElement _cardDiv;

  void set value(String newValue) {
    _value = newValue;
    valueToDisplay = revealed ? _value : "...";
  }

  String get value => _value;

  CardComponent.created() : super.created() {
  }

  factory CardComponent.revealCard(String playerName, String value, bool revealed, kickHandler) {
    CardComponent component = (new Element.tag("card-component") as CardComponent)
      ..playerName = playerName
      ..revealed = revealed
      ..value = value
      .._kickHandler = kickHandler;

    return component;
  }

  void attached() {
    super.attached();

    _cardDiv = $["card"];
    setSelected();

    _kickButton = $["kickPlayer"]
      ..onClick.listen((e) => _kickHandler(playerName));
  }

  void setSelected() {
    _cardDiv.classes.toggle("selected", revealed ? false : value != "");
  }

  void selectCard(Event e) {
    _cardDiv.classes.toggle("selected");
  }
}