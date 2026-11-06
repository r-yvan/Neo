import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus { ok, serviceOff, denied, deniedForever, unavailable }

class LocationFix {
  const LocationFix(this.status, {this.latitude, this.longitude});

  final LocationStatus status;
  final double? latitude;
  final double? longitude;

  bool get ok => status == LocationStatus.ok;
}

/// Thin wrapper over geolocator that never throws: every failure becomes a
/// [LocationStatus] the UI can explain.
abstract final class LocationService {
  static Future<LocationFix> current({bool request = true}) async {
    try {
      if (!kIsWeb && !await Geolocator.isLocationServiceEnabled()) {
        return const LocationFix(LocationStatus.serviceOff);
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && request) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationFix(LocationStatus.deniedForever);
      }
      if (permission == LocationPermission.denied) {
        return const LocationFix(LocationStatus.denied);
      }
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationFix(LocationStatus.ok,
          latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      if (!kIsWeb) {
        try {
          final Position? last = await Geolocator.getLastKnownPosition();
          if (last != null) {
            return LocationFix(LocationStatus.ok,
                latitude: last.latitude, longitude: last.longitude);
          }
        } catch (_) {}
      }
      return const LocationFix(LocationStatus.unavailable);
    }
  }

  static Future<void> openSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }
}
