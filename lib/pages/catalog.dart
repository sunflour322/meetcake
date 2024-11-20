import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetcake/database/collections/meets_collection.dart';
import 'package:meetcake/database/collections/user_collection.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/pages/meet_create.dart';
import 'package:meetcake/theme_lng/change_lng.dart';
import 'package:meetcake/user_service/user_service.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:meetcake/maps/map_services/yandex_map_service.dart';
import 'package:meetcake/theme_lng/change_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapControllerCompleter = Completer<YandexMapController>();
  List<MapObject> mapObjects = [];
  MeetsCRUD _meetsCRUD = MeetsCRUD();
  UserCRUD _userCRUD = UserCRUD();
  String? meetId;
  String? username;
  //MeetsCRUD _meetsCRUD = MeetsCRUD();
  TextEditingController searchController = TextEditingController();
  SearchItem? selectedMapObjectName;
  List<SearchItem> searchResults = [];
  LocaleProvider localeProvider = LocaleProvider();
  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    //places = await fetchPlaces(location.lat, location.long);
    //displayPlacesOnMap(places);
    addObjects(appLatlong: location);
    _moveToCurrentLocation(location);
  }

  void addObjects({required AppLatLong appLatlong}) {
    final myLocationMarker = PlacemarkMapObject(
      opacity: 1,
      mapId: const MapObjectId('currentLantLong'),
      point: Point(latitude: appLatlong.lat, longitude: appLatlong.long),
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
        scale: 0.3,
        image: BitmapDescriptor.fromAssetImage('assets/placemark.png'),
        rotationType: RotationType.noRotation,
      )),
    );
    mapObjects.add(myLocationMarker);
    setState(() {});
  }

  Future<void> _moveToCurrentLocation(AppLatLong appLatLong) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 3),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: appLatLong.lat, longitude: appLatLong.long),
          zoom: 15,
        ),
      ),
    );
  }

  Future<void> _search() async {
    final query = searchController.text;
    final resultWithSession = await YandexSearch.searchByText(
      searchText: query,
      geometry: Geometry.fromBoundingBox(
        const BoundingBox(
          southWest: Point(latitude: 55.7, longitude: 37.5),
          northEast: Point(latitude: 55.75, longitude: 37.61),
        ),
      ),
      searchOptions: SearchOptions(
        searchType: SearchType.biz,
        origin: '${localeProvider.locale}',
        geometry: false,
      ),
    );

    final result = await resultWithSession.$2;
    setState(() {
      searchResults = result.items ?? [];
    });
  }

  void _clearSearch() {
    setState(() {
      searchResults = [];
    });
  }

  Future<void> _displaySelectedPlaceOnMap(SearchItem selectedItem) async {
    // Clear any previous search markers
    mapObjects
        .removeWhere((mapObject) => mapObject.mapId.value == 'selectedPlace');

    // Add a marker for the selected place
    final placeMarker = PlacemarkMapObject(
      onTap: (mapObject, point) async {
        final currentUserName = await _userCRUD.fetchUsername();
        meetId = await _meetsCRUD.addMeet(
            point.latitude,
            point.longitude,
            '${selectedItem.businessMetadata?.name}' +
                ' (${selectedItem.businessMetadata?.address.formattedAddress})',
            currentUserName!);
        if (meetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetCreatePage(
                  searchItem: selectedItem, point: point, meetId: meetId),
            ),
          );
        }
        print(meetId);
      },
      opacity: 1,
      mapId: const MapObjectId('selectedPlace'),
      point: selectedItem.geometry.first.point!,
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
        scale: 0.2,
        image: BitmapDescriptor.fromAssetImage(
            'assets/circle.png'), // Customize the icon if needed
        rotationType: RotationType.noRotation,
      )),
    );

    mapObjects.add(placeMarker); // Add the marker to the map
    setState(() {});

    // Move camera to the selected location
    await _moveToResultLocation(selectedItem.geometry.first.point!);
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  void addMark({required Point point}) {
    final onTapLocation = PlacemarkMapObject(
      onTap: (mapObject, point) async {
        final currentUserName = await _userCRUD.fetchUsername();
        meetId = await _meetsCRUD.addMeet(
            point.latitude, point.longitude, '', currentUserName!);
        if (meetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetCreatePage(
                point: point,
                searchItem: selectedMapObjectName,
                meetId: meetId,
              ),
            ),
          );
          print(meetId);
        }
      },
      opacity: 1,
      mapId: const MapObjectId('onTapLocation'),
      point: point,
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
        scale: 0.2,
        image: BitmapDescriptor.fromAssetImage('assets/circle.png'),
        rotationType: RotationType.noRotation,
      )),
    );
    //_meetsCRUD.addMeet(name, lat, long, usersID)
    print(point);
    mapObjects.add(onTapLocation);
    setState(() {});
  }

  Future<void> _moveToResultLocation(Point point) async {
    final controller = await mapControllerCompleter.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 16),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
    final username = _userCRUD.fetchUsername();
  }

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
          child: Stack(
        children: [
          Container(
            height:
                MediaQuery.of(context).size.height, // Ограничиваем высоту карты
            child: YandexMap(
              mapObjects: mapObjects,
              // onMapTap: (argument) {
              //   addMark(point: argument);
              // },
              onMapLongTap: (argument) {
                addMark(point: argument);
              },
              onMapCreated: (controller) {
                mapControllerCompleter.complete(controller);
              },
              nightModeEnabled: themeProvider.returnBoolTheme(),
            ),
          ),
          //buildPlaceList(places),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 20, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/meets');
                    },
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: BoxDecoration(
                            color: themeProvider.theme.primaryColorLight
                                .withOpacity(0.3),
                            border: Border.all(
                                width: 2,
                                style: BorderStyle.solid,
                                color: Colors.white),
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.asset(
                          'assets/minilogo.png',
                          scale: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ClipRect(
                    // Ограничивает область размытия
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10.0, sigmaY: 10.0, tileMode: TileMode.decal),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              style: BorderStyle.solid,
                              width: 2,
                              color: Colors.white),
                          color: themeProvider.theme.primaryColorLight
                              .withOpacity(0.3),
                        ),
                        // Полупрозрачный фон
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            onChanged: (value) {
                              _search();
                            },
                            controller: searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                            decoration: InputDecoration(
                              hintText: S.of(context).search,
                              hintStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                              suffixIcon: IconButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20), // Радиус скругления
                                    ),
                                  ),
                                  side: MaterialStateProperty.all<BorderSide>(
                                    BorderSide(
                                      color: Colors.white, // Цвет границы
                                      width: 3, // Толщина границы
                                    ),
                                  ),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10), // Внутренний отступ
                                  ),
                                ),
                                onPressed: () {
                                  _search();
                                },
                                icon: Icon(Icons.search),
                                color: Colors.white,
                              ),
                              border: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 3),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 3),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 3),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                            cursorColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (searchResults.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            style: BorderStyle.solid,
                            width: 3,
                            color: Colors.white),
                        color: themeProvider.theme.primaryColorDark
                            .withOpacity(0.6)),
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final item = searchResults[index];
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                                style: BorderStyle.solid,
                                width: 2,
                                color: themeProvider.theme.primaryColorLight
                                    .withOpacity(0.3)),
                          ),
                          child: ListTile(
                            titleAlignment: ListTileTitleAlignment.center,
                            leading: Icon(Icons.zoom_in),
                            title: Text(item.businessMetadata?.name ?? '',
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                              item.businessMetadata?.address.formattedAddress ??
                                  '',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _moveToResultLocation(item.geometry.first.point!);
                              _displaySelectedPlaceOnMap(item);
                              _clearSearch();
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(148, 185, 255, 1),
        child: Icon(
          Icons.place_outlined,
          size: 40,
        ),
        onPressed: () {
          _initPermission();
        },
      ),
    );
  }
}
