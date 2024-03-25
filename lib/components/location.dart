import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';

class GeoLocatorHandler {
  String? errorMessage;
  GeoCoord? lastKnownPosition;
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
