import 'dart:convert' show JSON;
import 'list_items.dart';

class ListEntry {

  var id = new DateTime.now().millisecondsSinceEpoch;
  String name;
  var cost;
  List<String> shareWith = [];
  List<ListItem> items = [];
  bool remove = false;

  ListEntry();

  ListEntry.create(this.name, {this.shareWith, this.items});

  ListEntry.fromJson(Map json) {
    this.name = json['name'];
    this.cost = json['cost'];
    this.shareWith = json['shareWith'];
    this.items = json['items'];
  }

  String getCost() {
    return cost.toString();
  }

  toJson() {
    return JSON.encode({
      "name": name,
      "costs": getCost(),
      "shareWith": shareWith,
      "items": items
    });
  }
}