import 'package:dio/dio.dart';

class SensorEventService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8000/api",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<bool> sendMovementEvent({
    required String patientId,
    required double intensity,
  }) async {
    try {
      final response = await _dio.post(
        "/events/movement/",
        data: {
          "patient_id": patientId,
          "intensity": intensity,
          "timestamp": DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Fehler beim Senden: $e");
      return false;
    }
  }
}
