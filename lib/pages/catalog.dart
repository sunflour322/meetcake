import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/user_service/service.dart';
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
  TextEditingController searchController = TextEditingController();
  final List<SearchSessionResult> results = [];

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
      searchOptions: const SearchOptions(
        searchType: SearchType.biz, // Focus on business locations
        geometry: true,
      ),
    );

    _showSearchResults(resultWithSession.$2);
  }

  void _showOrganizationDetails(SearchItemBusinessMetadata? metadata) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(metadata?.name ?? "Организация"),
          content: Column(
            children: [
              if (metadata?.address.formattedAddress != null)
                Text("Адрес: ${metadata?.address.formattedAddress}"),
              // if (metadata.description != null)
              //   Text("Описание: ${metadata.description}"),
              // Добавьте виджет Image.network() для показа фото, если URL доступен
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(Future<SearchSessionResult> searchResults) {
    searchResults.then((result) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Search Results for '${searchController.text}'"),
          content: SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: result.items?.length ?? 0,
              itemBuilder: (context, index) {
                final item = result.items![index];
                return ListTile(
                  title: Text(item.businessMetadata!.name),
                  onTap: () {
                    _moveToResultLocation(item.geometry.first.point!);
                    Navigator.of(context).pop();
                    _showOrganizationDetails(item.businessMetadata);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  void addMark({required Point point}) {
    final onTapLocation = PlacemarkMapObject(
      opacity: 1,
      mapId: const MapObjectId('onTapLocation'),
      point: point,
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
        scale: 0.3,
        image: BitmapDescriptor.fromAssetImage('assets/placemark.png'),
        rotationType: RotationType.noRotation,
      )),
    );
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
              height: MediaQuery.of(context)
                  .size
                  .height, // Ограничиваем высоту карты
              child: YandexMap(
                mapObjects: mapObjects,
                onMapTap: (argument) {
                  addMark(point: argument);
                },
                onMapCreated: (controller) {
                  mapControllerCompleter.complete(controller);
                },
                nightModeEnabled: themeProvider.returnBoolTheme(),
              ),
            ),
            //buildPlaceList(places),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 50, 20, 0),
              child: TextFormField(
                controller: searchController,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: S.of(context).search,
                  labelStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                  suffixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 3),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 3),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 3),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                cursorColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //authService.logOut();
          //String category = 'cafe';
          _search();
        },
      ),
    );
  }
}
