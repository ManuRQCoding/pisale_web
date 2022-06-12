import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pisale_web/pages/tests/widgets/themes/autocomplete_tests.dart';

import '../../models/test.dart';

Future<T?> showCreateThemeDialog<T>(
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
  late TextEditingController controllerSubtitle;
  final List<String> tests = [];

  @override
  void initState() {
    super.initState();
    final bool isNew = widget.item == null;
    controllerTitle =
        TextEditingController(text: isNew ? '' : widget.item!.get('title'));
    controllerSubtitle =
        TextEditingController(text: isNew ? '' : widget.item!.get('subtitle'));
    if (!isNew) {
      tests.addAll(List<String>.from(
          widget.item!.get('tests').map((x) => x.toString())));
    }
  }

  addTest(QueryDocumentSnapshot<Object?> test) {
    setState(() {
      tests.add(Test.fromFirebaseObject(test).id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final palette = Theme.of(context).colorScheme;
    final bool isNew = widget.item == null;

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
            TextField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              controller: controllerSubtitle,
              decoration: InputDecoration(
                labelText: 'Subtítulo',
                hintText:
                    controllerSubtitle.text == '' ? 'Introduce un valor' : '',
                enabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            AutocompleteTestsData(handleOnSelect: addTest),
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
                    children: tests
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
                                          tests.remove(e);
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
            'subtitle': controllerSubtitle.text,
            'tests': tests
          }),
        )
      ],
    );
  }
}
