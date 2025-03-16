import 'package:flutter_mobile_command_tools/enum/sim_operation_type.dart';

/// 操作指令的集合
class SimOperationModel {
  /// 所有指令
  List<SimOperation> simOperationList = [];

  /// 是否为单条指令，默认一个文件包含多条指令时候，将会执行文件中的所有指令
  bool isSingle = false;
}

class SimOperation {
  /// 滑动和点击第一个点的x坐标
  int x1 = 0;

  /// 滑动和点击第一个点的y坐标
  int y1 = 0;

  /// 滑动第二个点的x坐标
  int x2 = 0;

  /// 滑动第二个点的y坐标
  int y2 = 0;

  /// 滑动类型
  SwipeType swipeType = SwipeType.SWIPE_CUSTOM;

  /// 模拟指令类型
  SimOperationType simOperationType = SimOperationType.SWIPE;

  /// text、adb、other文本
  String text = "";

  /// 指令别名
  String aliasName = "";
}
