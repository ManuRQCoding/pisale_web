import 'package:flutter/material.dart';
import 'package:pisale_web/pages/tests/models/question.dart';

class QuestionProvider extends ChangeNotifier {
  bool editing = false;
  Question? editingQuestion;

  startEditing(Question question) {
    editing = true;
    editingQuestion = question;
    notifyListeners();
  }

  stopEditing() {
    editing = false;
    editingQuestion = null;
    notifyListeners();
  }
}
