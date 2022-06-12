import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class RemoveTestsProv extends ChangeNotifier {
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
    final coll = FirebaseFirestore.instance.collection('tests');
    final collThemes = FirebaseFirestore.instance.collection('themes');
    selecteds.forEach((element) {
      coll.doc(element.id).delete();
      collThemes
          .where('tests', arrayContains: element.id)
          .get()
          .then((value) => value.docs.forEach((theme) {
                theme.reference.update({
                  'tests': theme.get('tests').where((test) =>
                      !selecteds.map((e) => e.id).toList().contains(test)),
                });
              }));
    });
  }
}
