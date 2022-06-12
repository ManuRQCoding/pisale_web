// To parse this JSON data, do
//
//     final test = testFromMap(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Test {
  Test({
    required this.id,
    required this.title,
    required this.questions,
  });

  String id;
  String title;
  List<String>? questions;

  factory Test.fromFirebaseObject(QueryDocumentSnapshot<Object?> object) =>
      Test(
          id: object.id,
          title: object.get('title'),
          questions: List<String>.from(object.get('questions')));
}
