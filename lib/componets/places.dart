/* WORK IN PROGRESS */
/* Mnsdk problem with  flutter_google_places_sdk*/
/*import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:google_directions_api/google_directions_api.dart';

class HumanDirPlacesSearch {
  late final FlutterGooglePlacesSdk _places;
  String googlePlacesApiKey;

  HumanDirPlacesSearch({required this.googlePlacesApiKey});

  void initState() {
    _places = FlutterGooglePlacesSdk(googlePlacesApiKey);
    _places.isInitialized().then((value) {
      print('Places Initialized: $value');
    });
  }
  void searchNerbyPlacesByCoords(GeoCoord coordsFrom, GeoCoord coordsTo) async{
    LatLng from = LatLng(lat: coordsFrom.latitude, lng: coordsFrom.longitude);
    LatLng to = LatLng(lat: coordsTo.latitude, lng: coordsFrom.longitude);
    LatLngBounds _locationBias = LatLngBounds(southwest: from, northeast: to);
    /*final result = await _places.findAutocompletePredictions(
        _predictLastText!,
        countries: _countriesEnabled ? _countries : null,
        placeTypesFilter: _placeTypesFilter,
        newSessionToken: false,
        origin: LatLng(lat: 43.12, lng: 95.20),
        locationBias: _locationBiasEnabled ? _locationBias : null,
        locationRestriction:
            _locationRestrictionEnabled ? _locationRestriction : null,
      );*/
  }
}
*/