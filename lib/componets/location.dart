import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class GeolocatorAppExample extends StatelessWidget {
  const GeolocatorAppExample({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Obtener Posición GPS'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              getLocation(context);
            },
            child: const Text('Obtener Ubicación'),
          ),
        ),
      ),
    );
  
 }
 Future<String> getLocation(BuildContext context) async {
    
        LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(!context.mounted) return 'Context error';
        _askLocationPermisionDialog(context);
        return 'Permission missing';
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  }
  Future <void> _askLocationPermisionDialog(BuildContext context){
     BuildContext localContext = context;
    return showDialog <void>(
          context: localContext,
          builder: (BuildContext localContext) {
            return AlertDialog(
              title: const Text('Permiso denegado'),
              content: const Text('Por favor, concede permisos de ubicación para usar esta función.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
  }
}
