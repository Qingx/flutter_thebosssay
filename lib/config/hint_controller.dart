import 'package:get/get.dart';

class HintController extends GetxController {
  var hint = "请输入内容".obs;

  setHint(String text) {
    hint.firstRebuild = true;
    hint.value = text;

    update();
  }
}
