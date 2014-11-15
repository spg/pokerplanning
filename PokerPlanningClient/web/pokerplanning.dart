import 'dart:html';

Map<String, String> players = {
};
String myName;

void main() {
  querySelector("#loginButton").onClick.listen(login);
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

  if(myName.isEmpty) return;

  hideLoginForm();
  showLoginSuccessful();
  showGame();
}