import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<T?> showCreateUserDialog<T>(BuildContext context,
        {required String title,
        required QueryDocumentSnapshot<Object?>? item,
        required bool editing}) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        item: item,
        editing: editing,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final QueryDocumentSnapshot<Object?>? item;
  final bool editing;

  const TextDialogWidget(
      {Key? key,
      required this.title,
      required this.editing,
      required this.item})
      : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controllerName;
  late TextEditingController controllerPassword;

  @override
  void initState() {
    super.initState();
    final bool isNew = widget.item == null;
    controllerName =
        TextEditingController(text: isNew ? '' : widget.item!.get('name'));
    controllerPassword =
        TextEditingController(text: isNew ? '' : widget.item!.get('password'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final palette = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title.toUpperCase(),
          style: TextStyle(color: palette.primary)),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 150,
        ),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              controller: controllerName,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: controllerName.text == '' ? 'Introduce un valor' : '',
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
              controller: controllerPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText:
                    controllerPassword.text == '' ? 'Introduce un valor' : '',
                enabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),
              ),
            ),
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
            'name': controllerName.text,
            'password': controllerPassword.text,
            'errors': widget.item == null ? 0 : widget.item!.get('errors'),
            'exam_count':
                widget.item == null ? 0 : widget.item!.get('exam_count'),
            'exam_fails':
                widget.item == null ? 0 : widget.item!.get('exam_fails'),
            'exam_passed':
                widget.item == null ? 0 : widget.item!.get('exam_passed'),
            'rights': widget.item == null ? 0 : widget.item!.get('rights'),
          }),
        )
      ],
    );
  }
}
