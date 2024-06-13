import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/global.dart';

/// @description: 路由信息记录
/// @time 2024/5/23 16:15
/// @author lijie
/// @email jackyli706@gmail.com
class RouteListener<R extends Route<dynamic>> extends RouteObserver<R> {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    String? routeName = route.settings.name;
    if (routeName == null) {
      return;
    }
    Global.routeName.add(routeName);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    String? routeName = route.settings.name;
    if (routeName == null) {
      return;
    }
    Global.routeName.remove(routeName);
  }
}
