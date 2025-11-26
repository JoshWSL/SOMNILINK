import 'dart:async';
import 'dart:math';
import 'package:motion_sensors/motion_sensors.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  // Listener
  StreamSubscription? _accelSub;

  // Letzte Bewegung
  double _smoothedMagnitude = 0.0;
  DateTime? _lastMovementTime;

  // Events-Callback
  Function(double intensity)? onMovementDetected;

  // Konfiguration
  static const double movementThreshold = 1.3; // g-Kraft Schwelle
  static const double smoothingFactor = 0.7;

  void start() {
    // Stream starten
    _accelSub = motionSensors.accelerometer.listen((event) {
      final magnitude = sqrt(
        event.x * event.x +
        event.y * event.y +
        event.z * event.z,
      );

      // Glättung
      _smoothedMagnitude =
          smoothingFactor * _smoothedMagnitude +
          (1 - smoothingFactor) * magnitude;

      // Bewegung erkannt
      if (_smoothedMagnitude > movementThreshold) {
        final intensity = _smoothedMagnitude - movementThreshold;

        // Nur Event senden, wenn nicht schon vor < 1s erkannt
        if (_lastMovementTime == null ||
            DateTime.now().difference(_lastMovementTime!) >
                const Duration(milliseconds: 800)) {
          _lastMovementTime = DateTime.now();

          if (onMovementDetected != null) {
            onMovementDetected!(intensity);
          }
        }
      }
    });
  }

  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
  }
}
