import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pisale_web/pages/tests/models/question.dart';
import 'package:pisale_web/pages/tests/widgets/tests/autocomplete_questions.dart';
import 'package:pisale_web/pages/tests/widgets/themes/autocomplete_tests.dart';

import '../../models/test.dart';

Future<T?> showCreateTestDialog<T>(
  BuildContext context, {
  required String title,
  required QueryDocumentSnapshot<Object?>? item,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        item: item,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final QueryDocumentSnapshot<Object?>? item;

  const TextDialogWidget({
    Key? key,
    required this.title,
    required this.item,
  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controllerTitle;

  final List<String> questions = [];

  @override
  void initState() {
    super.initState();
    final bool isNew = widget.item == null;
    controllerTitle =
        TextEditingController(text: isNew ? '' : widget.item!.get('title'));
    if (!isNew) {
      questions.addAll(List<String>.from(
          widget.item!.get('questions').map((x) => x.toString())));
    }
  }

  addQuestion(QueryDocumentSnapshot<Object?> question) {
    setState(() {
      questions.add(Question.fromFirebaseObject(question).id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final palette = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title.toUpperCase(),
          style: TextStyle(color: palette.primary)),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              controller: controllerTitle,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText:
                    controllerTitle.text == '' ? 'Introduce un valor' : '',
                enabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              height: 25,
            ),
            AutocompleteQuestionsData(handleOnSelect: addQuestion),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: palette.tertiary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    children: questions
                        .map((e) => Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: palette.tertiary,
                                  borderRadius: BorderRadius.circular(5)),
                              child: IntrinsicWidth(
                                child: Row(
                                  children: [
                                    Text(
                                      e,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        print('hola');
                                        setState(() {
                                          questions.remove(e);
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(palette.secondary),
          ),
          child: Text(
            'Hecho',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop({
            'title': controllerTitle.text,
            'questions': questions,
          }),
        )
      ],
    );
  }
}
