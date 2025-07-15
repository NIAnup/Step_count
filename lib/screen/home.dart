import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/step_controller.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final StepController controller = Get.find<StepController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4CB578),
        flexibleSpace: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Step",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Steps Today: ${controller.steps}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Source: ${controller.source}',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: controller.fetchSteps,
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFF4CB578),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.shade400, blurRadius: 1),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Refresh",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              // ElevatedButton(
              //   onPressed: controller.fetchSteps,
              //   child: Text("Refresh"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
