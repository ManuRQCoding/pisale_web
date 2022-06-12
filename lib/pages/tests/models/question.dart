// To parse this JSON data, do
//
//     final question = questionFromMap(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pisale_web/pages/tests/models/answer.dart';

class Question {
  Question({
    required this.id,
    required this.answers,
    required this.content,
    required this.help,
    required this.image,
  });

  String id;
  List<Answer> answers;
  String content;
  String help;
  String? image;
  Answer? selected;

  factory Question.fromFirebaseObject(QueryDocumentSnapshot<Object?> object) =>
      Question(
        id: object.id,
        content: object.get('content'),
        help: object.get('help'),
        image: object.get('image'),
        answers: List<Answer>.from(
            object.get('answers').map((x) => Answer.fromMap(x))),
      );
}
