import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:step_count/controller/step_controller.dart';
import 'package:step_count/screen/home.dart';

import 'bindings/step_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.activityRecognition.request();
  await Permission.sensors.request();
  Get.put(StepController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: Home(),
      initialBinding: StepBinding(),
    );
  }
}
