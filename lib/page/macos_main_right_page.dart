import 'package:flutter/cupertino.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/model/text_field_model.dart';
import 'package:flutter_mobile_command_tools/widgets/log_widget.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosMainRightPage extends StatefulWidget {
  final Widget centerWidget;
  final TextFieldModel textFieldModel;

  const MacosMainRightPage(this.centerWidget, this.textFieldModel, {Key? key})
      : super(key: key);

  @override
  State<MacosMainRightPage> createState() => _MacosMainRightPageState();
}

class _MacosMainRightPageState extends State<MacosMainRightPage> {
  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text(Constants.APP_NAME),
        leading: MacosTooltip(
          message: 'Toggle Sidebar',
          useMousePosition: false,
          child: MacosIconButton(
            icon: MacosIcon(
              CupertinoIcons.sidebar_left,
              color: MacosTheme.brightnessOf(context).resolve(
                const Color.fromRGBO(0, 0, 0, 0.5),
                const Color.fromRGBO(255, 255, 255, 0.5),
              ),
              size: 20.0,
            ),
            boxConstraints: const BoxConstraints(
              minHeight: 20,
              minWidth: 20,
              maxWidth: 48,
              maxHeight: 38,
            ),
            onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
          ),
        ),
      ),
      children: [
        // ResizablePane(
        //   minSize: 180,
        //   startSize: 200,
        //   windowBreakpoint: 700,
        //   resizableSide: ResizableSide.right,
        //   builder: (_, __) {
        //     return widget.centerWidget;
        //   },
        // ),
        ContentArea(
          builder: (_, __) {
            return Row(
              children: [
                Container(
                  width: 100,
                  margin: EdgeInsets.all(10),
                ),
                Expanded(child: LogWidget())
              ],
            );
          },
        ),
        // const ResizablePane.noScrollBar(
        //   minSize: 180,
        //   startSize: 200,
        //   windowBreakpoint: 700,
        //   resizableSide: ResizableSide.right,
        //   child: Center(child: Text('Right non-scrollable Resizable Pane')),
        // ),
      ],
    );
  }
}
