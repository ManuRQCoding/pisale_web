import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pisale_web/pages/routes/directions_provider.dart';
import 'package:pisale_web/pages/routes/models/map_route.dart';
import 'package:pisale_web/pages/routes/providers/edit_route_provider.dart';
import 'package:pisale_web/pages/routes/utils/routes_utils.dart';
import 'package:pisale_web/pages/routes/widgets/create_route_dialog.dart';
import 'package:provider/provider.dart';

import '../../properties.dart';
import '../../widgets/drawer/drawer_menu.dart';
import 'models/directions.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({Key? key}) : super(key: key);

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final editRoutesProv = Provider.of<EditRouteProvider>(context);

    return Scaffold(
      backgroundColor: Color(palette['background']!),
      appBar: AppBar(
        backgroundColor: Color(palette['primary']!),
        elevation: 5,
        foregroundColor: Color(palette['secondary']!),
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoutesUtils.routessStream(size),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  editRoutesProv.editing ? 'Editar ruta' : 'Crear ruta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(palette['tertiary']!),
                  ),
                ),
              ),
              GoogleMapsRoute(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleMapsRoute extends StatefulWidget {
  const GoogleMapsRoute({Key? key}) : super(key: key);

  @override
  State<GoogleMapsRoute> createState() => _GoogleMapsRouteState();
}

class _GoogleMapsRouteState extends State<GoogleMapsRoute> {
  static CameraPosition _initialCameraPosition =
      CameraPosition(target: LatLng(37.773972, -122.431297), zoom: 15.5);
  GoogleMapController? _googleMapController;

  Marker? _origin;
  Marker? _destination;
  late List<LatLng> polylinePoints;

  Directions? _info;
  @override
  void initState() {
    // TODO: implement initState
    // getDirections();

    polylinePoints = [];

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final editRoutesProv = Provider.of<EditRouteProvider>(context);
    if (editRoutesProv.editingItem != null) {
      final route = MapRoute.fromFirebaseObject(editRoutesProv.editingItem!);
      polylinePoints = route.polylinePoints
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();
      _initialCameraPosition = CameraPosition(
          target: LatLng(route.origin.latitude, route.origin.longitude),
          zoom: 15.5);
      editRoutesProv.editingItem = null;
    }
    return Column(
      children: [
        Container(
          width: size.width * 0.5,
          height: size.height * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
                width: 7,
                color: Color(
                  palette['tertiary']!,
                )),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            polylines: {
              if (polylinePoints.isNotEmpty)
                Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: polylinePoints)
            },
            onTap: (pos) => _addMarker(pos),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (editRoutesProv.editing)
                FloatingActionButton(
                  onPressed: () {
                    editRoutesProv.stopEditing();
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
                  back();
                },
                child: Icon(
                  Icons.keyboard_double_arrow_left,
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
                    final name = await showCreateRouteDialog(context,
                        title: 'Crear ruta', value: '');

                    if (name != null) {
                      final map = {
                        'name': name,
                        'initialCameraPos': GeoPoint(
                            polylinePoints.first.latitude,
                            polylinePoints.first.longitude),
                        'origin': GeoPoint(polylinePoints.first.latitude,
                            polylinePoints.first.longitude),
                        'destination': GeoPoint(polylinePoints.last.latitude,
                            polylinePoints.last.longitude),
                        'polylinePoints': polylinePoints
                            .map((e) => GeoPoint(e.latitude, e.longitude))
                            .toList(),
                        'zoom': 15.5
                      };
                      if (editRoutesProv.editing) {
                        FirebaseFirestore.instance
                            .collection('routes')
                            .doc(editRoutesProv.itemId)
                            .update(map);
                        editRoutesProv.stopEditing();
                      } else {
                        FirebaseFirestore.instance
                            .collection('routes')
                            .add(map);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          editRoutesProv.editing
                              ? 'Actualizar ruta'
                              : 'Añadir ruta',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.route, color: Colors.white)
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ],
    );
  }

  _addMarker(LatLng pos) async {
    print('longpress');
    print(pos.latitude);
    if (_origin == null) {
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
      });
    } else if (_origin != null && _destination != null) {
      setState(() {
        _origin = null;
        _destination = null;
      });
    } else {
      setState(() {
        _destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
            position: pos);
      });

      setState(() {
        polylinePoints.addAll([_origin!.position, _destination!.position]);
      });
    }
  }

  back() {
    if (_destination != null && _origin != null) {
      setState(() {
        _destination = null;
        _origin = null;
        polylinePoints.removeLast();
        polylinePoints.removeLast();
      });
    } else if ((_destination != null || _origin != null)) {
      setState(() {
        _destination = null;
        _origin = null;
      });
    } else if (polylinePoints.isNotEmpty) {
      setState(() {
        _destination = null;
        _origin = null;
        polylinePoints.removeLast();
        polylinePoints.removeLast();
      });
    }
  }
}
