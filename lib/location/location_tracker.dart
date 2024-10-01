import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class LocationTracker {
  Position? previousPosition;
  final Logger logger = Logger();

  void initLocation(Function(double) onDistanceUpdate) async {
    await _determinePosition();

    Geolocator.getPositionStream().listen((Position position) {
      if (previousPosition != null) {
        double distance = calculateDistance(previousPosition!, position);
        onDistanceUpdate(distance);
      }
      previousPosition = position;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.e('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.e('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.e('Location permissions are permanently denied, we cannot request permissions.');
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // If permissions are granted, get the initial position
    previousPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  double calculateDistance(Position prev, Position current) {
    const double R = 6371e3; // Radius of the earth in meters
    final double lat1 = prev.latitude;
    final double lon1 = prev.longitude;
    final double lat2 = current.latitude;
    final double lon2 = current.longitude;

    final double phi1 = lat1 * (pi / 180);
    final double phi2 = lat2 * (pi / 180);
    final double deltaPhi = (lat2 - lat1) * (pi / 180);
    final double deltaLambda = (lon2 - lon1) * (pi / 180);

    final double a = (sin(deltaPhi / 2) * sin(deltaPhi / 2)) +
        (cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }
}
