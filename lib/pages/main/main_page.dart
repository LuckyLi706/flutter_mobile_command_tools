import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/base/base_state_page.dart';
import 'package:flutter_mobile_command_tools/generated/l10n.dart';
import 'package:flutter_mobile_command_tools/route/route_helper.dart';

/// @description: 主页面
/// @time 2024/5/23 14:06
/// @author lijie
/// @email jackyli706@gmail.com
class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends BaseStatePage<MainPage> {
  @override
  Widget buildMainWidget() {
    return Container();
  }

  @override
  Widget? barRightWidget() {
    return IconButton(
        tooltip: S.of(context).setting,
        onPressed: () {
          RouteHelper.getInstance().pushName(RouteHelper.settingPage);
        },
        icon: Icon(
          Icons.settings,
          color: Colors.white.withOpacity(0.9),
        ));
  }

  @override
  Widget? barLeftWidget() {
    return Container();
  }
}
