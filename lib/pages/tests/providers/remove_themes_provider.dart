import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RemoveThemesProv extends ChangeNotifier {
  final List<QueryDocumentSnapshot<Object?>> selecteds = [];

  addSelected(QueryDocumentSnapshot<Object?> item) {
    selecteds.add(item);

    notifyListeners();
  }

  removeSelected(QueryDocumentSnapshot<Object?> item) {
    selecteds.removeWhere((e) => e.id == item.id);
    notifyListeners();
  }

  removeSelecteds() {
    final coll = FirebaseFirestore.instance.collection('themes');
    selecteds.forEach((element) {
      coll.doc(element.id).delete();
    });
  }
}
