import 'package:flutter/material.dart';
import '../models/clipboard_item.dart';

class ClipboardProvider extends ChangeNotifier {
  List<ClipboardItem> _items = [];

  List<ClipboardItem> get items => _items;

  void addItem(ClipboardItem item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void setItems(List<ClipboardItem> items) {
    _items = items;
    notifyListeners();
  }
}
