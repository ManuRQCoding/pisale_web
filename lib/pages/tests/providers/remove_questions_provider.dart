import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RemoveQuestionsProv extends ChangeNotifier {
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
    final coll = FirebaseFirestore.instance.collection('questions');
    final collTests = FirebaseFirestore.instance.collection('tests');
    selecteds.forEach((element) {
      coll.doc(element.id).delete();
      collTests
          .where('questions', arrayContains: element.id)
          .get()
          .then((value) => value.docs.forEach((test) {
                test.reference.update({
                  'questions': test.get('questions').where((question) =>
                      !selecteds.map((e) => e.id).toList().contains(question)),
                });
              }));
    });
  }
}
