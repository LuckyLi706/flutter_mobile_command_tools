import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/base/base_controller.dart';

/// @description: 主页面控制层
/// @time 2024/6/13 14:54
/// @author lijie
/// @email jackyli706@gmail.com
class MainController extends BaseController {
  final TextEditingController logTextController = TextEditingController();
  final FocusNode leftPanelFocus = FocusNode();
  final ScrollController logTextScrollController = ScrollController();
  final ScrollController mainScrollController = ScrollController();

  String showLogText = '';

  ///更新信息
  ///每次都定位到最后一行
  ///移动光标位置到最后
  /// _logTextController.selection = TextSelection.fromPosition(
  ///     TextPosition(offset: _logTextController.text.length));
  /// FocusScope.of(leftPanelState.context).requestFocus(leftPanelFocus);
  /// 延迟移除光标闪烁
  void updateLog(String msg) {
    if (msg.isEmpty) {
      return;
    }
    if (showLogText.isEmpty) {
      showLogText = ">>>>>>>" + showLogText + msg.trim();
    } else {
      showLogText = showLogText + "\n" + ">>>>>>>" + msg.trim();
    }
    logTextController.text = showLogText;
    Future.delayed(Duration(milliseconds: 200), () {
      logTextScrollController.animateTo(
        logTextScrollController.position.maxScrollExtent, //滚动到底部
        //滚动到底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      //FocusScope.of(leftPanelState.context).requestFocus(leftPanelFocus);
    });
  }

  @override
  void onDispose() {}

  @override
  void onInit() {}
}
