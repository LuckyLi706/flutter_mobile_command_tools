
import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:flutter_mobile_command_tools/page/main_page.dart';
import 'package:flutter_mobile_command_tools/utils/init_utils.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitUtils.init({}); //等待配置初始化完成

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
    return MaterialApp(
      navigatorKey: Global.navigatorKey,
      home: MainPage(
      ),
    );
  }
}
