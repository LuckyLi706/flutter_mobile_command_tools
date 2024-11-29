import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/notifier/center_widget_change_notifier.dart';
import 'package:provider/provider.dart';
import '../platform_menus.dart';
import '../widgets/hover_widget.dart';
import '../widgets/vertical_app_bar.dart';
import 'main_right_page.dart';
import 'main_center_page.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: menuBarItems(),
      child: Scaffold(body: _mainWidget()),
    );
  }

  Widget _mainWidget() {
    return ChangeNotifierProvider<CenterWidgetChangeNotifier>(
      create: (_) => CenterWidgetChangeNotifier(),
      child: VerticalTabs(
        initialIndex: pageIndex,
        tabs: [
          HoverWidget(
            hoverEnterColor: VerticalTabs.color,
            hoverExitColor: VerticalTabs.defaultColor,
            child: Icon(
              CupertinoIcons.device_phone_portrait,
              size: 15,
            ),
          ),
          HoverWidget(
            hoverEnterColor: VerticalTabs.color,
            hoverExitColor: VerticalTabs.defaultColor,
            child: Icon(
              CupertinoIcons.command,
              size: 15,
            ),
          ),
        ],
        contents: [
          MainRightPage(DeviceCenterPage()),
          MainRightPage(DeviceCommandPage())
        ],
        indicatorSide: IndicatorSide.start,
        tabsWidth: 50,
        onSelect: (index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
    );
  }

  final List<NavigationRailDestination> destinations = const [
    NavigationRailDestination(
        icon: Icon(
          CupertinoIcons.device_phone_portrait,
          size: 15,
        ),
        label: Text("手机")),
    NavigationRailDestination(
        icon: Icon(
          CupertinoIcons.command,
          size: 15,
        ),
        label: Text("命令")),
  ];
}
