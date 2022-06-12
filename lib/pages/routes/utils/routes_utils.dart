import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pisale_web/pages/routes/providers/edit_route_provider.dart';
import 'package:provider/provider.dart';

import '../../../properties.dart';
import '../../../utils/utils.dart';
import '../providers/remove_routes_provider.dart';

class RoutesUtils {
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
  static StreamBuilder<QuerySnapshot<Map<String, dynamic>>> routessStream(
      Size size) {
    final coll = FirebaseFirestore.instance.collection('routes');
    return StreamBuilder(
        stream: coll.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final data = snapshot.data!.docs;
          final removeRoutesProv = Provider.of<RemoveRoutesProv>(context);

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
                          'Rutas',
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
                            heroTag: 'remove-button-routes',
                            onPressed: () {
                              removeRoutesProv.removeSelecteds();
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

  static Widget buildDataTable(BuildContext context, Size size,
      List<QueryDocumentSnapshot<Object?>> data) {
    final columns = ['ID', 'Nombre'];
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
    final removeRoutesProv = Provider.of<RemoveRoutesProv>(context);
    final editRoutesProv =
        Provider.of<EditRouteProvider>(context, listen: false);

    return data.map((QueryDocumentSnapshot<Object?> item) {
      final cells = [item.id, item.get('name')];

      return DataRow(
        selected: removeRoutesProv.selecteds.any((e) => e.id == item.id),
        onSelectChanged: (isSelected) {
          isSelected!
              ? removeRoutesProv.addSelected(item)
              : removeRoutesProv.removeSelected(item);
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
              editRoutesProv.startEditing(item);
            },
          );
        }),
      );
    }).toList();
  }
}
