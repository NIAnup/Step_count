import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';
import 'storage_service.dart';

class StepService {
  final Health _health = Health();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> getTodaySteps() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];

    try {
      final activityPermission = await Permission.activityRecognition.request();
      if (!activityPermission.isGranted) {
        print("Activity Recognition permission denied");
        return await handlePedometerFallback();
      }

      bool authorized = await _health.requestAuthorization(
        [HealthDataType.STEPS, HealthDataType.HEART_RATE],
        permissions: [HealthDataAccess.READ],
      );

      if (authorized) {
        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          types: types,
          startTime: startOfDay,
          endTime: now,
        );

        int totalSteps = healthData.fold(0, (sum, point) {
          if (point.value is NumericHealthValue) {
            return sum +
                (point.value as NumericHealthValue).numericValue.toInt();
          }
          return sum;
        });

        return {'steps': totalSteps, 'source': 'Health Connect'};
      } else {
        return await handlePedometerFallback();
      }
    } catch (e) {
      return await handlePedometerFallback();
    }
  }

  Future<Map<String, dynamic>> handlePedometerFallback() async {
    startPedometerListener();
    final saved = await _storage.getTodaySteps();
    return {'steps': saved['steps'], 'source': 'Pedometer'};
  }

  void startPedometerListener() {
    try {
      Pedometer.stepCountStream.listen(
        (StepCount event) async {
          final String today = DateTime.now().toIso8601String().split("T")[0];
          final int currentSteps = event.steps;

          await _storage.saveSteps(today, {
            'steps': currentSteps,
            'lastUpdated': DateTime.now().toUtc().toIso8601String(),
          });
        },
        onError: (error) {
          print("Pedometer Error: $error");
        },
      );
    } catch (e) {
      print("Pedometer init failed: $e");
    }
  }
}
