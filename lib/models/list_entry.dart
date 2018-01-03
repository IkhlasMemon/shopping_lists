import 'dart:convert' show JSON;
import 'list_items.dart';

class ListEntry {
  String name;
  List<String> shareWith = [];
  List<ListItem> items = [];

  toJson() {
    return JSON.encode({
      "name": name,
      "shareWith": shareWith,
      "items": items
    });
  }
}