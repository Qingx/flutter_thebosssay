import 'package:get/get.dart';

class HintController extends GetxController {
  var hint = "-1".obs;
  var canUse = false.obs;

  setHint(String text) {
    hint.firstRebuild = true;
    hint.value = text;

    update();
  }

  setCanUse(bool can) {
    canUse.firstRebuild = true;
    canUse.value = can;

    update();
  }
}
