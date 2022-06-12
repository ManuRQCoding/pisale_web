import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import '../../models/test.dart';

class AutocompleteQuestionsData extends StatelessWidget {
  AutocompleteQuestionsData({Key? key, required this.handleOnSelect})
      : super(key: key);

  final ScrollController _scrollController = ScrollController();
  final Function(QueryDocumentSnapshot<Object?> test) handleOnSelect;
  List<QueryDocumentSnapshot<Object?>> _kOptions = [];

  getKOptions() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('questions').get();
    final list = snapshot.docs;
    _kOptions = list;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getKOptions();
    });
    final size = MediaQuery.of(context).size;

    return SizedBox(
      child: Autocomplete<QueryDocumentSnapshot<Object?>>(
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              labelText: 'Preguntas',
              hintText: 'Buscar preguntas...',
              enabledBorder: OutlineInputBorder(),
              border: OutlineInputBorder(),
            ),
            focusNode: focusNode,
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
              print('You just typed a new entry  $value');
            },
          );
        },
        optionsViewBuilder: (context, onSelected, options) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: SizedBox(
              height: 200,
              width: size.width * 0.8,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final list = options.toList();
                    final e = list[i];
                    return ListTile(
                      onTap: () => onSelected(e),
                      title: Text(e.get('content').toString()),
                      subtitle: Text(e.id.toString()),
                    );
                  },
                  separatorBuilder: (context, i) => const Divider(
                    height: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<QueryDocumentSnapshot<Object?>>.empty();
          }
          return _kOptions.where((QueryDocumentSnapshot<Object?> option) {
            return option
                    .get('content')
                    .toString()
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()) ||
                option.id
                    .toString()
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
            ;
          });
        },
        displayStringForOption: (QueryDocumentSnapshot<Object?> option) =>
            option.get('content').toString(),
        onSelected: (QueryDocumentSnapshot<Object?> selection) {
          handleOnSelect(selection);
        },
      ),
    );
  }
}
