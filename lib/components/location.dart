import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';

/// Controller class for geolocation has one method
///   - getLocation: its just to get the user location in a variable type  GeoCoord from package:google_directions_api
class GeoLocatorHandler {
  ///Any error message trwon by the class methos
  String? errorMessage;

  /// Last stored coord of the user
  GeoCoord? lastKnownPosition;

  /// Main method to get he location of the user.
  ///
  /// Parameters:
  ///   - context (BuildContext):  the build context is required to ask the user permission to use their location.
  ///
  /// Returns:
  ///   - null if theres an error, (sotred in errorMessage variable).
  ///   - GeoCooord if the request weas successful.
  Future<GeoCoord?> getLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) {
          errorMessage = 'Context not mounted';
          return null;
        }
        _askLocationPermisionDialog(context);
        errorMessage = 'User permission needed';
        return null;
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    lastKnownPosition = GeoCoord(position.latitude, position.longitude);
    return GeoCoord(position.latitude, position.longitude);
  }

  /// Method to get the user perrmission for the location, internal use.
  Future<void> _askLocationPermisionDialog(BuildContext context) {
    BuildContext localContext = context;
    return showDialog<void>(
      context: localContext,
      builder: (BuildContext localContext) {
        return AlertDialog(
          title: const Text('Permission denied'),
          content:
              const Text('Please, give the app permission to use this feature'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
