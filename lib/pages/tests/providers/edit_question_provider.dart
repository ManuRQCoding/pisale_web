import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class EditQuestionProvider extends ChangeNotifier {
  bool editing = false;
  QueryDocumentSnapshot<Object?>? editingItem;
  String? itemId;

  startEditing(QueryDocumentSnapshot<Object?> item) {
    editing = true;
    editingItem = item;
    itemId = item.id;
    notifyListeners();
  }

  stopEditing() {
    editing = false;
    editingItem = null;
    itemId = null;
    notifyListeners();
  }
}
