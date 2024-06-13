import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/route/route_helper.dart';

/// @description: appbar混入类
/// @time 2024/5/23 14:21
/// @author lijie
/// @email jackyli706@gmail.co
mixin AppBarMixin {
  AppBar? appBar() {
    return isShowAppBar()
        ? AppBar(
            centerTitle: true,
            title: appBarTitle() == null
                ? null
                : Text(
                    appBarTitle() ?? '',
                    style: TextStyle(color: Colors.white),
                  ),
            actions: [
              barRightWidget() ?? Container(),
            ],
            leading: barLeftWidget() ??
                IconButton(
                    onPressed: () {
                      RouteHelper.getInstance().pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    )),
          )
        : null;
  }

  ///appbar的名字
  String? appBarTitle() {
    return null;
  }

  ///是否展示appbar
  bool isShowAppBar() {
    return true;
  }

  //自定义bar右边的组件
  Widget? barRightWidget() {
    return null;
  }

  ///自定义bar左边的组件
  Widget? barLeftWidget() {
    return null;
  }
}
