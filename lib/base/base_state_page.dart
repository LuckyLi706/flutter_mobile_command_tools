import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/base/base_controller.dart';

import 'base_app_bar.dart';

/// @description:
/// @time 2024/5/23 14:13
/// @author lijie
/// @email jackyli706@gmail.com
abstract class BaseStatePageWithController<T extends StatefulWidget,
    S extends BaseController> extends State<T> with AppBarMixin {
  late S? controller;

  @override
  void initState() {
    super.initState();
    controller = buildController();
    controller?.onInit();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: buildMainWidget(),
    );
  }

  ///主页面
  Widget buildMainWidget();

  S? buildController() {
    return null;
  }
}

abstract class BaseStatePage<T extends StatefulWidget> extends State<T>
    with AppBarMixin {
  @override
  void dispose() {
    super.dispose();
  }

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
