import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/enum/sim_operation_type.dart';

import '../../model/sim_operation_model.dart';

/**
 * @FileName : android_sim_script_notifier
 * @Author : lijie
 * @Time : 2025/3/10 18:37
 * @Description :  模拟脚本的弹唱监听器
 */
class AndroidSimScriptNotifier extends ChangeNotifier {
  /// 类型
  SimOperationType _simOperationType = SimOperationType.SWIPE;

  /// 滑动类型
  SwipeType _swipeType = SwipeType.SWIPE_CUSTOM;

  /// 自定义文件名
  bool _isCustomFileName = false;

  bool get isCustomFileName => _isCustomFileName;

  set isCustomFileName(bool value) {
    _isCustomFileName = value;
    notifyListeners();
  }

  SwipeType get swipeType => _swipeType;

  set swipeType(SwipeType value) {
    _swipeType = value;
    notifyListeners();
  }

  /// 是否为单条指令，默认一个文件包含多条指令时候，将会执行文件中的所有指令
  bool _isSingle = false;

  /// 当前脚本的所有指令
  List<SimOperation> _simOperationList = [];

  int _simOperationIndex = 0;

  int get simOperationIndex => _simOperationIndex;

  set simOperationIndex(int value) {
    _simOperationIndex = value;
    notifyListeners();
  }

  SimOperationType get simOperationType => _simOperationType;

  set simOperationType(SimOperationType value) {
    _simOperationType = value;
    notifyListeners();
  }

  List<SimOperation> get simOperationList => _simOperationList;

  set simOperationList(List<SimOperation> value) {
    _simOperationList = value;
    notifyListeners();
  }

  bool get isSingle => _isSingle;

  set isSingle(bool value) {
    _isSingle = value;
    notifyListeners();
  }
}
