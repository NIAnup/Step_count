import 'package:get/get.dart';
import '../services/step_services.dart';

class StepController extends GetxController {
  final RxInt steps = 0.obs;
  final RxString source = 'Loading...'.obs;
  final StepService _stepService = StepService();

  @override
  void onInit() {
    super.onInit();
    fetchSteps();
  }

  void fetchSteps() async {
    final result = await _stepService.getTodaySteps();
    steps.value = result['steps'];
    source.value = result['source'];
  }
}
