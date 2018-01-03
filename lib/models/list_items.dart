class ListItem {
  String name;
  bool bought = false;

  toJson() {
    return {
      "name": name,
      "bought": bought
    };
  }
}