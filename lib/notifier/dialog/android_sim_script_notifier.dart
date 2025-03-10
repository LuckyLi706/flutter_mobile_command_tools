import 'package:fluent_ui/fluent_ui.dart';

/**
 * @FileName : android_sim_script_notifier
 * @Author : lijie
 * @Time : 2025/3/10 18:37
 * @Description :  模拟脚本的弹唱监听器
 */
class AndroidSimScriptNotifier extends ChangeNotifier {
  /// 类型
  int _simTypeIndex = 0;

  /// 是否循环执行
  bool _isRepeat = false;

  /// 是否间隔时间随机
  bool _isRandom = true;

  /// 是否为单条指令，默认一个文件包含多条指令时候，将会执行文件中的所有指令
  bool _isSingle = false;

  int get simTypeIndex => _simTypeIndex;

  set simTypeIndex(int value) {
    _simTypeIndex = value;
    notifyListeners();
  }

  bool get isSingle => _isSingle;

  set isSingle(bool value) {
    _isSingle = value;
    notifyListeners();
  }

  bool get isRandom => _isRandom;

  set isRandom(bool value) {
    _isRandom = value;
    notifyListeners();
  }

  bool get isRepeat => _isRepeat;

  set isRepeat(bool value) {
    _isRepeat = value;
    notifyListeners();
  }
}
