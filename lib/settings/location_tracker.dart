import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class LocationTracker {
  Position? previousPosition;
  final Logger logger = Logger();
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;
  final double distanceThreshold; // Make distance threshold configurable

  LocationTracker({this.distanceThreshold = 1.0}); // Default value is 1.0 meters

  // Initializes localization tracking
  void initLocation(
      Function(double) onDistanceUpdate,
      Function(String) onError,
      String localizedErrorTrackingFailed,
      String localizedErrorInitializing) async {
    cancelLocationTracking(); // Cancel any existing tracking
    try {
      await _determinePosition(); // Get initial position

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      _positionSubscription = _positionStream?.listen(
            (Position position) {
          _handlePositionUpdate(position, onDistanceUpdate);
        },
        onError: (error) {
          logger.e('Position stream error: $error');
          onError(localizedErrorTrackingFailed);
        },
      );
    } catch (e) {
      logger.e('Failed to initialize localization tracking: $e');
      onError(localizedErrorInitializing);
    }
  }

  // Handles position updates and calculates distance
  void _handlePositionUpdate(Position position, Function(double) onDistanceUpdate) {
    if (previousPosition != null) {
      double distance = calculateDistance(previousPosition!, position);
      if (distance > distanceThreshold) {
        onDistanceUpdate(distance);
        logger.i('Distance updated: $distance meters from ${previousPosition.toString()} to ${position.toString()}');
      }
    }
    previousPosition = position; // Update the previous position
  }

  // Determines initial position
  Future<void> _determinePosition() async {
    if (!await _checkLocationServices()) return;

    LocationPermission permission = await Geolocator.checkPermission();
    permission = await _handleLocationPermission(permission);
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      previousPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      logger.i('Initial position obtained: $previousPosition');
    }
  }

  Future<bool> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.e('Location services are disabled.');
      return false;
    }
    return true;
  }

  Future<LocationPermission> _handleLocationPermission(LocationPermission permission) async {
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.e('Location permissions are denied');
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.e('Location permissions are permanently denied');
      throw Exception('Location permissions are permanently denied');
    }

    return permission; // Return the resolved permission
  }

  double calculateDistance(Position prev, Position current) {
    const double R = 6371e3; // Earth's radius in meters
    final double lat1 = prev.latitude;
    final double lon1 = prev.longitude;
    final double lat2 = current.latitude;
    final double lon2 = current.longitude;

    final double phi1 = lat1 * (pi / 180);
    final double phi2 = lat2 * (pi / 180);
    final double deltaPhi = (lat2 - lat1) * (pi / 180);
    final double deltaLambda = (lon2 - lon1) * (pi / 180);

    final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Return the distance in meters
  }

  // Cancel tracking
  void cancelLocationTracking() {
    _positionSubscription?.cancel(); // Cancel the subscription
    _positionStream = null; // Clear the stream
    previousPosition = null; // Reset the previous position
    logger.i('Location tracking stopped.');
  }
}
