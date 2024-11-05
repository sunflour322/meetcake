import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/maps/map_services/yandex_map_service.dart';
import 'package:meetcake/theme_lng/change_theme.dart';
import 'package:meetcake/user_service/service.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapControllerCompleter = Completer<YandexMapController>();
  List<MapObject> mapObjects = [];
  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    addObjects(appLatlong: location);
    _moveToCurrentLocation(location);
  }

  Future<void> _moveToCurrentLocation(
    AppLatLong appLatLong,
  ) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 3),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  void addObjects({required AppLatLong appLatlong}) {
    final myLocationMarker = PlacemarkMapObject(
        opacity: 1,
        mapId: const MapObjectId('currentLantLong'),
        point: Point(latitude: appLatlong.lat, longitude: appLatlong.long),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            scale: 0.3,
            image: BitmapDescriptor.fromAssetImage('assets/placemark.png'),
            rotationType: RotationType.noRotation)));
    mapObjects.add(myLocationMarker);
    setState(() {});
  }

  void addMark({required Point point}) {
    final onTapLocation = PlacemarkMapObject(
        opacity: 1,
        mapId: const MapObjectId('onTapLocation'),
        point: point,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            scale: 0.3,
            image: BitmapDescriptor.fromAssetImage('assets/placemark.png'),
            rotationType: RotationType.noRotation)));
    mapObjects.add(onTapLocation);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }

  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(100.0),
            child: TextFormField(
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: S.of(context).name,
                labelStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
                suffixIcon: const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              cursorColor: Colors.white,
            ),
          ),
          YandexMap(
            mapObjects: mapObjects,
            onMapTap: (argument) {
              addMark(point: argument);
            },
            onMapCreated: (controller) {
              mapControllerCompleter.complete(controller);
            },
            nightModeEnabled: themeProvider.returnBoolTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // await _initPermission();
          authService.logOut();
        },
      ),
    );
  }
}
