import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pisale_web/pages/users/providers/remove_users.dart';
import 'package:provider/provider.dart';

import '../../../properties.dart';
import '../../../utils/utils.dart';
import '../widgets/create_user_dialog.dart';

class UsersUtils {
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
  static StreamBuilder<QuerySnapshot<Map<String, dynamic>>> usersStream(
      Size size) {
    final coll = FirebaseFirestore.instance.collection('users');

    return StreamBuilder(
        stream: coll.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final data = snapshot.data!.docs;
          final removeUsersProv = Provider.of<RemoveUsersProv>(context);
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
                          'Usuarios',
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
                            heroTag: 'remove-button-user',
                            onPressed: () {
                              removeUsersProv.removeSelecteds();
                            },
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          FloatingActionButton(
                            heroTag: 'add-button-user',
                            onPressed: () async {
                              final result = await showCreateUserDialog(context,
                                  title: 'Crear usuario',
                                  item: null,
                                  editing: false);
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
    final columns = [
      'ID',
      'Nombre',
      'Contraseña',
      'Número de examenes',
      'Examenes suspensos',
      'Examenes aprobados',
      'Errores',
      'Aciertos'
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
        rows: getRows(data, palette, context),
      ),
    );
  }

  static List<DataRow> getRows(List<QueryDocumentSnapshot<Object?>> data,
      ColorScheme palette, BuildContext context) {
    //final pdfDataProvider = Provider.of<PdfDataProvider>(context);
    return data.map((QueryDocumentSnapshot<Object?> item) {
      final cells = [
        item.id,
        item.get('name'),
        item.get('password'),
        item.get('exam_count'),
        item.get('exam_fails'),
        item.get('exam_passed'),
        item.get('errors'),
        item.get('rights')
      ];
      final removeUsersProv = Provider.of<RemoveUsersProv>(context);

      return DataRow(
        selected: removeUsersProv.selecteds.any((e) => e.id == item.id),
        onSelectChanged: (isSelected) {
          isSelected!
              ? removeUsersProv.addSelected(item)
              : removeUsersProv.removeSelected(item);
        },
        color: MaterialStateProperty.all(palette.surface),
        cells: Utils.modelBuilder(cells, (index, cell) {
          final showEditIcon = index == 7;

          return DataCell(
            Text(
              '${cell == "" ? "Introducir un valor" : cell}',
            ),
            //placeholder: invoiceItem.description == '',
            showEditIcon: showEditIcon,
            onTap: () async {
              final result = await showCreateUserDialog(context,
                  title: 'Editar usuario', item: item, editing: true);

              if (result != null) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(item.id)
                    .update(result);
              }
            },
          );
        }),
      );
    }).toList();
  }
}
