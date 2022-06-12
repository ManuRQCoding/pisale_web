import 'package:flutter/material.dart';

Future<T?> showCreateRouteDialog<T>(
  BuildContext context, {
  required String title,
  required String value,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        value: value,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;

  const TextDialogWidget({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controllerName;
  late TextEditingController controllerPassword;

  @override
  void initState() {
    super.initState();
    final bool isNew = widget.value == '' || widget.value == '0';
    controllerName = TextEditingController(text: isNew ? '' : widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final palette = Theme.of(context).colorScheme;
    final bool isNew = widget.value == '' || widget.value == '0';

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
                hintText: isNew ? 'Introduce un valor' : '',
                enabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),
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
          onPressed: () => Navigator.of(context).pop(
            controllerName.text,
          ),
        )
      ],
    );
  }
}
