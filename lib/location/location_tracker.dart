import 'package:geolocator/geolocator.dart'; // Importing geolocator for location services
import 'package:logger/logger.dart'; // Importing logger for logging messages
import 'dart:math'; // Importing dart:math for mathematical operations

// This class tracks the user's location and calculates the distance traveled.
class LocationTracker {
  Position? previousPosition; // Stores the previous position
  final Logger logger = Logger(); // Logger instance for logging

  // Initializes location tracking and calls onDistanceUpdate with distance updates
  void initLocation(Function(double) onDistanceUpdate) async {
    await _determinePosition(); // Determines the initial position

    // Listen to the position stream for updates
    Geolocator.getPositionStream().listen((Position position) {
      if (previousPosition != null) {
        double distance = calculateDistance(previousPosition!, position); // Calculate distance
        onDistanceUpdate(distance); // Update distance
      }
      previousPosition = position; // Update the previous position
    });
  }

  // Determines the user's current position and checks permissions
  Future<void> _determinePosition() async {
    bool serviceEnabled; // Variable to hold the state of location services
    LocationPermission permission; // Variable to hold location permission status

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.e('Location services are disabled.'); // Log error if services are disabled
      return Future.error('Location services are disabled.');
    }

    // Check current location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // Request permission
      if (permission == LocationPermission.denied) {
        logger.e('Location permissions are denied'); // Log error if permission denied
        return Future.error('Location permissions are denied');
      }
    }

    // Handle permanently denied permissions
    if (permission == LocationPermission.deniedForever) {
      logger.e('Location permissions are permanently denied, we cannot request permissions.'); // Log error
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the initial position if permissions are granted
    previousPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Calculates the distance between two positions using the Haversine formula
  double calculateDistance(Position prev, Position current) {
    const double R = 6371e3; // Radius of the earth in meters
    final double lat1 = prev.latitude; // Latitude of the previous position
    final double lon1 = prev.longitude; // Longitude of the previous position
    final double lat2 = current.latitude; // Latitude of the current position
    final double lon2 = current.longitude; // Longitude of the current position

    final double phi1 = lat1 * (pi / 180); // Convert latitude to radians
    final double phi2 = lat2 * (pi / 180); // Convert latitude to radians
    final double deltaPhi = (lat2 - lat1) * (pi / 180); // Difference in latitude in radians
    final double deltaLambda = (lon2 - lon1) * (pi / 180); // Difference in longitude in radians

    // Haversine formula for calculating distance
    final double a = (sin(deltaPhi / 2) * sin(deltaPhi / 2)) +
        (cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Return distance in meters
  }
}
