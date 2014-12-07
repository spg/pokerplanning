library card_component;

import 'package:polymer/polymer.dart';
import 'dart:html' show Event, Node, CustomEvent;
import 'dart:html';

@CustomTag('card-component')
class CardComponent extends PolymerElement {
  @published
  String playerName;
  @published
  bool revealed;

  CardComponent.created() : super.created();

  factory CardComponent(String playerName) =>
  (new Element.tag("card-component") as CardComponent)
    ..playerName = playerName;
}