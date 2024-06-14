import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/pages/main/main_controller.dart';

/// @description: 展示log信息的widget
/// @time 2024/6/13 15:43
/// @author lijie
/// @email jackyli706@gmail.com
class LogInfoWidget extends StatelessWidget {
  final MainController mainController;

  const LogInfoWidget({Key? key, required this.mainController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      scrollController: mainController.logTextScrollController,
      controller: mainController.logTextController,
      keyboardType: TextInputType.multiline,
      focusNode: mainController.leftPanelFocus,
      maxLines: null,
      enabled: false,
      //不限制行数
      autofocus: false,
      // 长按输入的文本, 设置是否显示剪切，复制，粘贴按钮, 默认是显示的
      enableInteractiveSelection: true,
      style: TextStyle(fontFamily: "simple", fontSize: 16),
      decoration: InputDecoration(
        hintText: "日志信息",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide()),
      ),
      onChanged: (value) {},
    );
  }
}
