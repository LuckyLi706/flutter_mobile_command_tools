import 'package:flutter/material.dart';

import 'base_app_bar.dart';

/// @description:
/// @time 2024/5/23 14:13
/// @author lijie
/// @email jackyli706@gmail.com
abstract class BaseStatePage<T extends StatefulWidget> extends State<T>
    with AppBarMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: buildMainWidget(),
    );
  }

  ///主页面
  Widget buildMainWidget();
}
