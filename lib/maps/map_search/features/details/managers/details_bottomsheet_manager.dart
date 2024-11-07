// import 'package:meetcake/maps/map_search/features/details/state/details_bottomsheet_ui_state.dart';
// import 'package:yandex_mapkit/yandex_mapkit.dart';

// final class DetailsBottomSheetManager {
//   DetailsBottomSheetUiState uiState(GeoObject geoObject) {
//     final uri = geoObject.uri;
//     final geoObjectType = geoObject.getGeoObjectType;

//     return DetailsBottomSheetUiState(
//       title: geoObject.name ?? "No title",
//       description: geoObject.descriptionText ?? "No description",
//       location: geoObject.geometry.firstOrNull?.point,
//       uri: uri?.path,
//       geoObjectType: geoObjectType,
//     );
//   }
// }

// extension _GeoObjectUri on GeoObject {
//   Uri? get uri =>
//       metadataContainer.get(UriObjectMetadata.factory)?.uris.firstOrNull;
// }

// extension _GeoObjectType on GeoObject {
//   GeoObjectType get getGeoObjectType {
//     final toponymGeoOjbect = metadataContainer
//         .get(SearchToponymObjectMetadata.factory)
//         ?.let((toponymObject) => ToponymGeoObject(
//               address: toponymObject.address.formattedAddress,
//             ));

//     if (toponymGeoOjbect == null) {
//       final businessGeoObject = metadataContainer
//           .get(SearchBusinessObjectMetadata.factory)
//           ?.let((businessObject) => BusinessGeoObject(
//                 name: businessObject.name,
//                 workingHours: businessObject.workingHours?.text,
//                 categories: businessObject.categories
//                     .map((it) => it.name)
//                     .takeIfNotEmpty()
//                     ?.toSet()
//                     .join(", "),
//                 phones: businessObject.phones
//                     .map((it) => it.formattedNumber)
//                     .takeIfNotEmpty()
//                     ?.join(", "),
//                 link: businessObject.links.firstOrNull?.link.href,
//               ));

//       return businessGeoObject ?? UndefinedGeoObject.instance;
//     }
//     return toponymGeoOjbect;
//   }
// }
