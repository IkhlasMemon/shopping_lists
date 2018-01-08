class ListItem {
  String name;
  bool bought = false;

  num get price => price != null ? price.toString() : 0.00;
  set price(num val) => price = val;

  toJson() {
    return {
      "name": name,
      "price": price,
      "bought": bought
    };
  }
}