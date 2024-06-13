import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/pages/main/main_page.dart';
import 'package:flutter_mobile_command_tools/pages/settings/setting_page.dart';

/// @description: 路由相关的管理
/// @time 2024/5/23 16:25
/// @author lijie
/// @email jackyli706@gmail.com
class RouteHelper {
  RouteHelper._internal();

  static final RouteHelper _instance = RouteHelper._internal();

  static RouteHelper getInstance() {
    return _instance;
  }

  ///主页
  static const String mainPage = '/';
  static const String settingPage = '/setting';

  ///静态路由注册表
  static Map<String, WidgetBuilder> routes = {
    mainPage: (context) => MainPage(),
    settingPage: (context) => SettingPage(),
  };

  ///拦截静态注册表
  static Route? onGenerateRoute<T extends Object>(RouteSettings settings) {
    if (settings.name == null || routes[settings.name] == null) {
      return null;
    }
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (context) {
        String? name = settings.name;
        if (name == null || routes[name] == null) {
          //name = noFoundPage;
        }
        Widget widget = routes[name]!(context);
        return widget;
      },
    );
  }

  ///如果onGenerateRoute不对找不到的路由做处理，就会回调该方法。如果onGenerateRoute处理了，就不回掉该方法
  // static Route unKnownRoute<T extends Object>(RouteSettings settings) {
  //   return MaterialPageRoute<T>(
  //     settings: settings,
  //     builder: (context) {
  //       return routes[noFoundPage]!(context);
  //     },
  //   );
  // }

  Future<dynamic> push(dynamic pageWidget) {
    return Navigator.of(Constants.navigatorKey.currentState!.context).push(
      MaterialPageRoute(builder: (context) => pageWidget),
    );
  }

  void pop({dynamic result}) {
    Navigator.of(Constants.navigatorKey.currentState!.context).pop(result);
  }

  Future<dynamic> pushName(String pageName, {dynamic arguments}) {
    return Navigator.of(Constants.navigatorKey.currentState!.context)
        .pushNamed(pageName, arguments: arguments);
  }
}
