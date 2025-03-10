import 'package:fluent_ui/fluent_ui.dart';

/**
 * @FileName : android_sim_script_notifier
 * @Author : lijie
 * @Time : 2025/3/10 18:37
 * @Description :  模拟脚本的弹唱监听器
 */
class AndroidSimScriptNotifier extends ChangeNotifier {
  int _simTypeIndex = 0;

  int get simTypeIndex => _simTypeIndex;

  set simTypeIndex(int value) {
    _simTypeIndex = value;
    notifyListeners();
  }
}
