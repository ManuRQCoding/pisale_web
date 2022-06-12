import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:pisale_web/pages/tests/models/question.dart';
import 'package:pisale_web/pages/tests/providers/edit_question_provider.dart';

import 'package:pisale_web/pages/tests/utils/test_utils.dart';
import 'package:pisale_web/properties.dart';
import 'package:provider/provider.dart';

import '../../widgets/drawer/drawer_menu.dart';

class TestsPage extends StatelessWidget {
  const TestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Color(palette['background']!),
        appBar: AppBar(
          backgroundColor: Color(palette['primary']!),
          elevation: 5,
          foregroundColor: Color(palette['secondary']!),
        ),
        drawer: DrawerMenu(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TestUtils.themesStream(size),
              TestUtils.testsStream(size),
              TestUtils.questionsStream(size),
              CreateQuestionWidget(size: size),
            ],
          ),
        ));
  }
}

class CreateQuestionWidget extends StatefulWidget {
  const CreateQuestionWidget({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  State<CreateQuestionWidget> createState() => _CreateQuestionWidgetState();
}

class _CreateQuestionWidgetState extends State<CreateQuestionWidget> {
  String? imageUrl;
  late TextEditingController _controllerQuestion;
  late TextEditingController _controllerHelp;

  late TextEditingController _controllerAnswers;
  late List<String> _answers;
  String? groupValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controllerQuestion = TextEditingController();
    _controllerHelp = TextEditingController();
    _controllerAnswers = TextEditingController();
    _answers = [];
  }

  uploadImageToStorage(PickedFile? pickedFile) async {
    Reference _reference = FirebaseStorage.instance
        .ref()
        .child('images/${pickedFile!.path.split('/').last}');
    await _reference
        .putData(
      await pickedFile.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    )
        .whenComplete(() async {
      await _reference.getDownloadURL().then((value) {
        setState(() {
          imageUrl = value;
        });
      });
    });
  }

  reset() {
    _controllerQuestion.clear();
    _controllerHelp.clear();
    _controllerAnswers.clear();
    setState(() {
      imageUrl = null;
      _answers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final editQuestionProv = Provider.of<EditQuestionProvider>(context);
    if (editQuestionProv.editingItem != null) {
      final item = Question.fromFirebaseObject(editQuestionProv.editingItem!);
      _controllerQuestion.text = item.content;
      _controllerHelp.text = item.help;
      imageUrl = item.image;
      _answers = item.answers.map((e) => e.content).toList();
      groupValue =
          item.answers.firstWhere((element) => element.correct).content;
      editQuestionProv.editingItem = null;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            editQuestionProv.editing ? 'Editar pregunta' : 'Crear preguntas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(palette['tertiary']!),
            ),
          ),
        ),
        Container(
          width: 600,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
                width: 5,
                color: Color(
                  palette['tertiary']!,
                )),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await ImagePickerPlugin()
                      .pickImage(source: ImageSource.gallery);
                  uploadImageToStorage(result);
                },
                child: imageUrl == null
                    ? Image.asset(
                        'assets/default.png',
                        width: 350,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl!,
                        width: 350,
                        height: 200,
                      ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: _controllerQuestion,
                decoration: InputDecoration(
                  labelText: 'Pregunta',
                  hintText: 'Introduce tu pregunta',
                  enabledBorder: OutlineInputBorder(),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: _controllerHelp,
                decoration: InputDecoration(
                  labelText: 'Texto de ayuda',
                  hintText: 'Introduce el texto de ayuda',
                  enabledBorder: OutlineInputBorder(),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                onSubmitted: (data) {
                  print(data);
                  setState(() {
                    groupValue ??= data;
                    _answers.add(data);
                  });
                },
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: _controllerAnswers,
                decoration: InputDecoration(
                  labelText: 'Respuestas',
                  hintText: 'Añadir respuestas',
                  enabledBorder: OutlineInputBorder(),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: _answers
                    .map((answ) => RadioListTile<String>(
                        activeColor: Color(palette['tertiary']!),
                        value: answ,
                        title: Row(
                          children: [
                            Text(answ),
                            IconButton(
                                splashRadius: 15,
                                onPressed: () {
                                  setState(() {
                                    _answers.remove(answ);
                                    if (answ == groupValue &&
                                        _answers.isNotEmpty) {
                                      groupValue = _answers.first;
                                    }
                                  });
                                },
                                icon: Icon(Icons.remove_circle_rounded,
                                    color: Colors.grey)),
                          ],
                        ),
                        groupValue: groupValue,
                        onChanged: (value) {
                          setState(() {
                            groupValue = value;
                          });
                        }))
                    .toList(),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (editQuestionProv.editing)
              FloatingActionButton(
                onPressed: () {
                  editQuestionProv.stopEditing();
                  reset();
                },
                child: Icon(
                  Icons.edit_off_sharp,
                  color: Colors.white,
                ),
              ),
            SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              onPressed: () {
                reset();
              },
              child: Icon(
                Icons.restart_alt_rounded,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color(palette['secondary']!))),
                onPressed: () async {
                  final map = {
                    'answers': _answers
                        .map((e) => {'content': e, 'correct': e == groupValue})
                        .toList(),
                    'content': _controllerQuestion.text,
                    'help': _controllerHelp.text,
                    'image': imageUrl
                  };
                  if (editQuestionProv.editing) {
                    await FirebaseFirestore.instance
                        .collection('questions')
                        .doc(editQuestionProv.itemId)
                        .update(map);

                    editQuestionProv.stopEditing();
                  } else {
                    await FirebaseFirestore.instance
                        .collection('questions')
                        .add(map);

                    reset();
                  }
                  reset();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        editQuestionProv.editing
                            ? 'Actualizar respuesta'
                            : 'Añadir pregunta',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.question_mark_rounded, color: Colors.white)
                    ],
                  ),
                ))
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
