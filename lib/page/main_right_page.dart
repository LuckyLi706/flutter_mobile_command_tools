import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/notifier/center_widget_change_notifier.dart';
import 'package:flutter_mobile_command_tools/widgets/log_widget.dart';
import 'package:provider/provider.dart';

class MainRightPage extends StatefulWidget {
  final Widget centerWidget;

  const MainRightPage(this.centerWidget, {Key? key}) : super(key: key);

  @override
  State<MainRightPage> createState() => _MainRightPageState();
}

class _MainRightPageState extends State<MainRightPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CenterWidgetChangeNotifier(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(builder: (BuildContext context,
              CenterWidgetChangeNotifier notifier, Widget? child) {
            return Row(
              children: [
                Container(
                  width: notifier.centerWidth,
                  margin: EdgeInsets.all(10),
                  child: widget.centerWidget,
                ),
                GestureDetector(
                  onTapDown: (details) {
                    notifier.isClick = true;
                  },
                  onHorizontalDragUpdate: (details) {
                    notifier.centerWidth += details.delta.dx;
                  },
                  onHorizontalDragEnd: (details) {
                    notifier.isClick = false;
                  },
                  child: MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight, // 手指光标
                      child: Row(
                        children: [
                          Container(
                            child: Column(),
                            width: 2,
                            color: Colors.amber
                          )
                        ],
                      )),
                ),
              ],
            );
          }),
          Expanded(child: LogWidget())
        ],
      ),
    );
  }
}
