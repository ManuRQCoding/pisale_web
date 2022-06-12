import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pisale_web/pages/tests/providers/remove_test_provider.dart';
import 'package:pisale_web/pages/tests/providers/remove_themes_provider.dart';
import 'package:pisale_web/pages/tests/widgets/tests/create_test_dialog.dart';
import 'package:pisale_web/pages/tests/widgets/themes/create_theme_dialog.dart';
import 'package:provider/provider.dart';

import '../../../properties.dart';
import '../../../utils/utils.dart';
import '../providers/edit_question_provider.dart';
import '../providers/remove_questions_provider.dart';

class TestUtils {
  //GENERAL
  static List<DataColumn> getColumns(List<String> columns) {
    return columns.map((String column) {
      return DataColumn(
        label: Text(
          column,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }).toList();
  }

  //TESTS
  static StreamBuilder<QuerySnapshot<Map<String, dynamic>>> testsStream(
      Size size) {
    final coll = FirebaseFirestore.instance.collection('tests');
    return StreamBuilder(
        stream: coll.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final data = snapshot.data!.docs;
          final removeTestsProv = Provider.of<RemoveTestsProv>(context);

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Tests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(palette['primary']!),
                          ),
                        ),
                      ),
                      buildDataTable(context, size, data),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            heroTag: 'remove-button-extra',
                            onPressed: () {
                              removeTestsProv.removeSelecteds();
                            },
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            heroTag: 'add-button-extra',
                            onPressed: () async {
                              final result = await showCreateTestDialog(context,
                                  title: 'Crear test', item: null);

                              if (result != null) {
                                coll.add(result);
                              }
                            },
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          // return ListView.separated(
          //     separatorBuilder: (context, index) => Divider(),
          //     itemCount: data.length,
          //     itemBuilder: (context, i) {
          //       final currentData = data[i];
          //       return Text(currentData.get('title'));
          //     });
        });
  }

  static Widget buildDataTable(BuildContext context, Size size,
      List<QueryDocumentSnapshot<Object?>> data) {
    final columns = ['ID', 'Título', 'Preguntas'];
    final palette = Theme.of(context).colorScheme;
    //final pdfDataProvider = Provider.of<PdfDataProvider>(context);
    return SizedBox(
      child: DataTable(
        columnSpacing: 25,
        headingRowColor: MaterialStateProperty.all(palette.primary),
        headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        decoration: BoxDecoration(border: Border.all(color: palette.primary)),
        columns: getColumns(columns),
        rows: getRows(data, palette, context),
      ),
    );
  }

  static List<DataRow> getRows(List<QueryDocumentSnapshot<Object?>> data,
      ColorScheme palette, BuildContext context) {
    //final pdfDataProvider = Provider.of<PdfDataProvider>(context);
    final removeTestsProv = Provider.of<RemoveTestsProv>(context);

    return data.map((QueryDocumentSnapshot<Object?> item) {
      final cells = [item.id, item.get('title'), item.get('questions')];

      return DataRow(
        selected: removeTestsProv.selecteds.any((e) => e.id == item.id),
        onSelectChanged: (isSelected) {
          isSelected!
              ? removeTestsProv.addSelected(item)
              : removeTestsProv.removeSelected(item);
        },
        color: MaterialStateProperty.all(palette.surface),
        cells: Utils.modelBuilder(cells, (index, cell) {
          final showEditIcon = index == 2;

          return DataCell(
            index == 2
                ? Wrap(children: [
                    ...(cell as List)
                        .sublist(0, min(2, cell.length))
                        .map((item) => Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: palette.tertiary,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ))
                        .toList(),
                    if (cell.length > 2)
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Icon(Icons.more_horiz, color: palette.tertiary),
                        ],
                      )
                  ])
                : Text(
                    '${cell == "" ? "Introducir un valor" : cell}',
                  ),
            //placeholder: invoiceItem.description == '',
            showEditIcon: showEditIcon,
            onTap: () async {
              final result = await showCreateTestDialog(context,
                  title: 'Editar test', item: item);
              if (result != null) {
                FirebaseFirestore.instance
                    .collection('tests')
                    .doc(item.id)
                    .update(result);
              }
            },
          );
        }),
      );
    }).toList();
  }

  //THEMES
  static StreamBuilder<QuerySnapshot<Map<String, dynamic>>> themesStream(
      Size size) {
    final coll = FirebaseFirestore.instance.collection('themes');

    return StreamBuilder(
        stream: coll.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final data = snapshot.data!.docs;
          final removeThemesProv = Provider.of<RemoveThemesProv>(context);

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Temas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(palette['primary']!),
                          ),
                        ),
                      ),
                      buildThemesDataTable(context, size, data),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            heroTag: 'remove-button-theme',
                            onPressed: () {
                              removeThemesProv.removeSelecteds();
                            },
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            heroTag: 'add-button-theme',
                            onPressed: () async {
                              final result = await showCreateThemeDialog(
                                  context,
                                  title: 'Crear tema',
                                  item: null);
                              if (result != null) {
                                coll.add(result);
                              }
                            },
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          // return ListView.separated(
          //     separatorBuilder: (context, index) => Divider(),
          //     itemCount: data.length,
          //     itemBuilder: (context, i) {
          //       final currentData = data[i];
          //       return Text(currentData.get('title'));
          //     });
        });
  }

  static Widget buildThemesDataTable(BuildContext context, Size size,
      List<QueryDocumentSnapshot<Object?>> data) {
    final columns = ['ID', 'Título', 'Subtítulo', 'Tests'];
    final palette = Theme.of(context).colorScheme;
    //final pdfDataProvider = Provider.of<PdfDataProvider>(context);
    return SizedBox(
      child: DataTable(
        columnSpacing: 25,
        headingRowColor: MaterialStateProperty.all(palette.primary),
        headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        decoration: BoxDecoration(border: Border.all(color: palette.primary)),
        columns: getColumns(columns),
        rows: getThemesRows(data, palette, context),
      ),
    );
  }

  static List<DataRow> getThemesRows(List<QueryDocumentSnapshot<Object?>> data,
      ColorScheme palette, BuildContext context) {
    //final pdfDataProvider = Provider.of<PdfDataProvider>(context);
    final removeThemesProv = Provider.of<RemoveThemesProv>(context);

    return data.map((QueryDocumentSnapshot<Object?> item) {
      final cells = [
        item.id,
        item.get('title'),
        item.get('subtitle'),
        item.get('tests')
      ];

      return DataRow(
        selected: removeThemesProv.selecteds.any((e) => e.id == item.id),
        onSelectChanged: (isSelected) {
          isSelected!
              ? removeThemesProv.addSelected(item)
              : removeThemesProv.removeSelected(item);
        },
        color: MaterialStateProperty.all(palette.surface),
        cells: Utils.modelBuilder(cells, (index, cell) {
          final showEditIcon = index == 1 || index == 2 || index == 3;

          return DataCell(
            index == 3
                ? Wrap(children: [
                    ...(cell as List)
                        .sublist(0, min(2, cell.length))
                        .map((item) => GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: FutureBuilder<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>(
                                            future: FirebaseFirestore.instance
                                                .collection('tests')
                                                .doc(item)
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return CircularProgressIndicator();
                                              }

                                              return Container(
                                                child: Text(snapshot.data!
                                                    .get('title')),
                                              );
                                            }),
                                      );
                                    });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: palette.tertiary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                    if (cell.length > 2)
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Icon(Icons.more_horiz, color: palette.tertiary),
                        ],
                      )
                  ])
                : Text(
                    '${cell == "" ? "Introducir un valor" : cell}',
                  ),
            //placeholder: invoiceItem.description == '',
            showEditIcon: showEditIcon,
            onTap: () async {
              final result = await showCreateThemeDialog(context,
                  title: 'Editar tema', item: item);
              if (result != null) {
                FirebaseFirestore.instance
                    .collection('themes')
                    .doc(item.id)
                    .update(result);
              }
            },
          );
        }),
      );
    }).toList();
  }

  //QUESTIONS
  static StreamBuilder<QuerySnapshot<Map<String, dynamic>>> questionsStream(
      Size size) {
    final coll = FirebaseFirestore.instance.collection('questions');
    return StreamBuilder(
        stream: coll.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final data = snapshot.data!.docs;
          final removeQuestionsProv = Provider.of<RemoveQuestionsProv>(context);

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Preguntas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(palette['primary']!),
                          ),
                        ),
                      ),
                      buildQuestionsDataTable(context, size, data),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            heroTag: 'remove-button-theme',
                            onPressed: () {
                              removeQuestionsProv.removeSelecteds();
                            },
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          // return ListView.separated(
          //     separatorBuilder: (context, index) => Divider(),
          //     itemCount: data.length,
          //     itemBuilder: (context, i) {
          //       final currentData = data[i];
          //       return Text(currentData.get('title'));
          //     });
        });
  }

  static Widget buildQuestionsDataTable(BuildContext context, Size size,
      List<QueryDocumentSnapshot<Object?>> data) {
    final columns = [
      'ID',
      'Pregunta',
    ];
    final palette = Theme.of(context).colorScheme;
    //final pdfDataProvider = Provider.of<PdfDataProvider>(context);

    return SizedBox(
      child: DataTable(
        columnSpacing: 25,
        headingRowColor: MaterialStateProperty.all(palette.primary),
        headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
        dataRowColor: MaterialStateProperty.all(Colors.white),
        decoration: BoxDecoration(border: Border.all(color: palette.primary)),
        columns: getColumns(columns),
        rows: getQuestionsRows(data, palette, context),
      ),
    );
  }

  static List<DataRow> getQuestionsRows(
      List<QueryDocumentSnapshot<Object?>> data,
      ColorScheme palette,
      BuildContext context) {
    //final pdfDataProvider = Provider.of<PdfDataProvider>(context);
    final removeQuestionsProv = Provider.of<RemoveQuestionsProv>(context);
    final editQuestionProv = Provider.of<EditQuestionProvider>(context);

    return data.map((QueryDocumentSnapshot<Object?> item) {
      final cells = [
        item.id,
        item.get('content'),
      ];

      return DataRow(
        selected: removeQuestionsProv.selecteds.any((e) => e.id == item.id),
        onSelectChanged: (isSelected) {
          isSelected!
              ? removeQuestionsProv.addSelected(item)
              : removeQuestionsProv.removeSelected(item);
        },
        color: MaterialStateProperty.all(palette.surface),
        cells: Utils.modelBuilder(cells, (index, cell) {
          final showEditIcon = index == 1;

          return DataCell(
            Text(
              '${cell == "" ? "Introducir un valor" : cell}',
            ),
            //placeholder: invoiceItem.description == '',
            showEditIcon: showEditIcon,
            onTap: () {
              editQuestionProv.startEditing(item);
            },
          );
        }),
      );
    }).toList();
  }
}
