import 'dart:async';
import 'package:geolocator/geolocator.dart'; // Importing geolocator for location services
import 'package:logger/logger.dart'; // Importing logger for logging messages
import 'dart:math'; // Importing dart:math for mathematical operations

// This class tracks the user's location and calculates the distance traveled.
class LocationTracker {
  Position? previousPosition; // Stores the previous position
  final Logger logger = Logger(); // Logger instance for logging
  Stream<Position>? _positionStream; // To hold the position stream
  static const double distanceThreshold = 1.0; // Minimum significant distance in meters

  // Initializes location tracking and calls onDistanceUpdate with distance updates
  void initLocation(Function(double) onDistanceUpdate) async {
    cancelLocationTracking(); // Cancel any existing tracking before starting a new one
    await _determinePosition(); // Determines the initial position

    // Set up the position stream to listen for updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Optional: Minimum distance (in meters) before updates are triggered
      ),
    );

    // Listen to the position stream for updates
    _positionStream?.listen((Position position) {
      _handlePositionUpdate(position, onDistanceUpdate);
    });
  }

  // Handles position updates and calculates distance
  void _handlePositionUpdate(Position position, Function(double) onDistanceUpdate) {
    if (previousPosition != null) {
      double distance = calculateDistance(previousPosition!, position); // Calculate distance
      if (distance > distanceThreshold) { // Only update if the distance is significant
        onDistanceUpdate(distance); // Update distance
        logger.i('Distance updated: $distance meters'); // Log the distance update
      }
    }
    previousPosition = position; // Update the previous position
  }

  // Determines the user's current position and checks permissions
  Future<void> _determinePosition() async {
    // Check if location services are enabled
    if (!await _checkLocationServices()) return;

    // Check current location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    permission = await _handleLocationPermission(permission);

    // Get the initial position if permissions are granted
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      previousPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      logger.i('Initial position obtained: $previousPosition');
    }
  }

  // Checks if location services are enabled
  Future<bool> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.e('Location services are disabled.'); // Log error if services are disabled
      return false;
    }
    return true;
  }

  // Handles the location permission status and requests permission if necessary
  Future<LocationPermission> _handleLocationPermission(LocationPermission permission) async {
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // Request permission
      if (permission == LocationPermission.denied) {
        logger.e('Location permissions are denied'); // Log error if permission denied
        throw Exception('Location permissions are denied');
      }
    }

    // Handle permanently denied permissions
    if (permission == LocationPermission.deniedForever) {
      logger.e('Location permissions are permanently denied, cannot request permissions.'); // Log error
      throw Exception('Location permissions are permanently denied, cannot request permissions.');
    }

    return permission;
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

  // Cancel the position stream subscription when it's no longer needed
  void cancelLocationTracking() {
    _positionStream?.drain(); // Cancel the stream subscription
    previousPosition = null; // Reset previous position
    logger.i('Location tracking stopped.');
  }
}
