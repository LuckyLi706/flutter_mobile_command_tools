import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:flutter_mobile_command_tools/page/macos_main_page.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> main() async {
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

      ///themeMode: appTheme.mode,
      debugShowCheckedModeBanner: false,
      home: MainMacosWidget(),
    );
  }
}
