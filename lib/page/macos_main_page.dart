import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mobile_command_tools/mixin/mixin_main.dart';
import 'package:flutter_mobile_command_tools/model/text_field_model.dart';
import 'package:flutter_mobile_command_tools/page/main_center_page.dart';
import 'package:flutter_mobile_command_tools/page/macos_main_right_page.dart';
import 'package:macos_ui/macos_ui.dart';
import '../platform_menus.dart';

class MainMacosWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainMacosWidgetState();
  }
}

class _MainMacosWidgetState extends State<MainMacosWidget> with MixinMain {
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    textEditingController.text = "222";
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: menuBarItems(),
      child: MacosWindow(
        sidebar: Sidebar(
          minWidth: 200,
          builder: (context, scrollController) {
            return SidebarItems(
              currentIndex: pageIndex,
              onChanged: (i) {
                if (kIsWeb && i == 10) {
                } else {
                  setState(() => pageIndex = i);
                }
              },
              scrollController: scrollController,
              itemSize: SidebarItemSize.large,
              items: [
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.device_phone_portrait),
                  label: Text('设备'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.arrow_counterclockwise),
                  label: Text('连接'),
                ),
              ],
            );
          },
          bottom: const MacosListTile(
            leading: MacosIcon(CupertinoIcons.settings),
            title: Text('设置'),
          ),
        ),
        child: [
          MacosMainRightPage(
              DeviceCenterPage(),
              TextFieldModel(
                  scrollController, textEditingController, focusNode)),
          MacosMainRightPage(
              Text('thank you'),
              TextFieldModel(
                  scrollController, textEditingController, focusNode)),
        ][pageIndex],
      ),
    );
  }
}
