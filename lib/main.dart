import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:flutter_mobile_command_tools/page/macos_main_page.dart';
import 'package:flutter_mobile_command_tools/utils/init_utils.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitUtils.init({}); //等待配置初始化完成
  if (!kIsWeb) {
    if (Platform.isMacOS) {
      await _configureMacosWindowUtils();
    }
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<LogChangeNotifier>(
          create: (_) => LogChangeNotifier()),
    ],
    child: MainWidget(),
  ));
}

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: Constants.APP_NAME,
      navigatorKey: Global.navigatorKey,

      ///themeMode: appTheme.mode,
      debugShowCheckedModeBanner: false,
      home: MainMacosWidget(),
    );
  }
}
