import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:provider/provider.dart';

class AndroidLogWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextBox(
      scrollController:
          Provider.of<LogChangeNotifier>(context).scrollController,
      keyboardType: TextInputType.multiline,
      controller: TextEditingController(
          text: Provider.of<LogChangeNotifier>(context).logList.join('\n')),

      ///     focusNode: leftPanelFocus,
      readOnly: true,
      maxLines: null,
      //不限制行数
      autofocus: false,
      // 长按输入的文本, 设置是否显示剪切，复制，粘贴按钮, 默认是显示的
      enableInteractiveSelection: true,
      style: TextStyle(fontFamily: "simple", fontSize: 16),
      padding: EdgeInsets.all(10),
      decoration: WidgetStateProperty.resolveWith<BoxDecoration>((state) {
        return BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(5)));
      }),
    );
  }
}
