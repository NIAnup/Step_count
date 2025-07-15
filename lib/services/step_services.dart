import 'dart:async';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';
import 'storage_service.dart';

class StepService {
  final Health _health = Health();
  final StorageService _storage = StorageService();
  int? _baseSteps;
  final StreamController<int> _stepStreamController =
      StreamController<int>.broadcast();

  Stream<int> get stepStream => _stepStreamController.stream;

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
        types,
        permissions: permissions,
      );

      if (authorized) {
        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          types: types,
          startTime: startOfDay,
          endTime: now,
        );

        final seen = <String>{};
        healthData =
            healthData.where((point) {
              final key = "${point.dateFrom.toIso8601String()}_${point.value}";
              if (seen.contains(key)) return false;
              seen.add(key);
              return true;
            }).toList();

        int totalSteps = healthData.fold(0, (sum, point) {
          if (point.value is NumericHealthValue) {
            return sum +
                (point.value as NumericHealthValue).numericValue.toInt();
          }
          return sum;
        });

        _stepStreamController.add(totalSteps);
        return {'steps': totalSteps, 'source': 'Health Connect'};
      } else {
        print("Health Connect authorization denied");
        return await handlePedometerFallback();
      }
    } catch (e) {
      print("Health Connect exception: $e");
      return await handlePedometerFallback();
    }
  }

  Future<Map<String, dynamic>> handlePedometerFallback() async {
    startPedometerListener();
    final saved = await _storage.getTodaySteps();
    print("Pedometer fallback loaded: $saved");
    _stepStreamController.add(saved['steps'] ?? 0);
    return {'steps': saved['steps'] ?? 0, 'source': 'Pedometer'};
  }

  void startPedometerListener() {
    try {
      Pedometer.stepCountStream.listen(
        (StepCount event) async {
          final String today = DateTime.now().toIso8601String().split("T")[0];
          final int currentSensorSteps = event.steps;

          if (_baseSteps == null) {
            final saved = await _storage.getTodaySteps();
            _baseSteps = saved['base'] ?? currentSensorSteps;

            if (saved['base'] == null) {
              await _storage.saveSteps(today, {
                'steps': 0,
                'base': currentSensorSteps,
                'lastUpdated': DateTime.now().toUtc().toIso8601String(),
              });
              print("Initialized base steps: $_baseSteps");
            }
          }

          int dailySteps =
              currentSensorSteps - (_baseSteps ?? currentSensorSteps);
          if (dailySteps < 0) dailySteps = 0;

          print("Pedometer daily steps calculated: $dailySteps");

          await _storage.saveSteps(today, {
            'steps': dailySteps,
            'base': _baseSteps,
            'lastUpdated': DateTime.now().toUtc().toIso8601String(),
          });

          _stepStreamController.add(dailySteps);
        },
        onError: (error) {
          print("Pedometer Error: $error");
        },
      );
    } catch (e) {
      print("Pedometer init failed: $e");
    }
  }

  void dispose() {
    _stepStreamController.close();
  }
}
