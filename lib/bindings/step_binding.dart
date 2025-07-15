import 'package:get/get.dart';
import '../controller/step_controller.dart';

class StepBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StepController>(() => StepController());
  }
}
