import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:flutter_mobile_command_tools/notifier/panel/android_panel_notifier.dart';
import 'package:flutter_mobile_command_tools/utils/command_utils.dart';
import 'package:flutter_mobile_command_tools/utils/dialog_utils.dart';
import 'package:flutter_mobile_command_tools/utils/style_utils.dart';
import 'package:flutter_mobile_command_tools/widgets/android_panel.dart';
import 'package:flutter_mobile_command_tools/theme.dart';
import 'package:flutter_mobile_command_tools/utils/init_utils.dart';
import 'package:flutter_mobile_command_tools/widgets/dialog/android_disconnect_device_dialog.dart';
import 'package:flutter_mobile_command_tools/widgets/dialog/android_sim_script_dialog.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;

import 'global.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

///目前保存adb路径(自定义的)，是否root开启，是否启用内部路径
Map<String, dynamic> _settings = {};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setMinimumSize(const Size(500, 600));
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  await InitUtils.init(_settings); //等待配置初始化完成

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LogChangeNotifier()),
      ChangeNotifierProvider(create: (context) => AndroidPanelNotifier()),
    ],
    child: MyApp(),
  ));
}

final _appTheme = AppTheme();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appTheme,
      builder: (context, child) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          key: Global.navigatorKey,
          title: "222",
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          home: Main(),
          // routeInformationParser: router.routeInformationParser,
          // routerDelegate: router.routerDelegate,
          // routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}

class Main extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Main> {
  var selectId = 0;

  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(flutter_material.Icons.android),
      title: const Text('Android'),
      body: AndroidPanel(),
    ),
    PaneItem(
      icon: const Icon(flutter_material.Icons.local_pharmacy_outlined),
      title: const Text('Harmony'),
      body: Column(),
    )
  ];

  List<NavigationPaneItem> footerItems = [
    PaneItem(
      icon: const Icon(flutter_material.Icons.settings),
      title: const Text('设置'),
      body: Column(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      key: Global.scaffoldKey,
      pane: NavigationPane(
          selected: selectId,
          footerItems: this.footerItems,
          onChanged: (index) {
            selectId = index;
            setState(() {});
          },
          header: null,
          items: items,
          displayMode: PaneDisplayMode.compact),
      appBar: NavigationAppBar(
        height: 40,
        backgroundColor: Colors.grey.withAlpha(50),
        title: () {
          return DragToMoveArea(
              child: MenuBar(
            items: [
              MenuBarItem(title: '连接', items: [
                MenuFlyoutItem(
                    text: Text(
                      '刷新设备',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {
                      AndroidCommandUtils.sendConnectDeviceOrder();
                    }),
                MenuFlyoutItem(
                    text: Text(
                      '无线连接',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                MenuFlyoutItem(
                    text: Text(
                      '断开连接',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () async {
                      bool? isConfirm =
                          await DialogUtils.showConfirmOrCancelDialog<bool>(
                              AndroidDisconnectDeviceDialog());
                    }),
              ]),
              MenuBarItem(title: '应用交互', items: [
                MenuFlyoutItem(
                    text: Text(
                      'Activity',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                MenuFlyoutItem(
                    text: Text(
                      'Service',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                MenuFlyoutItem(
                    text: Text(
                      'BroadCastReceiver',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
              ]),
              MenuBarItem(title: '逆向', items: [
                MenuFlyoutItem(
                    text: Text(
                      '签名',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                MenuFlyoutItem(
                    text: Text(
                      '签名校验',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                const MenuFlyoutSeparator(),
                ToggleMenuFlyoutItem(
                    text: Text(
                      '-f',
                      style: getCommonTitleStyle(),
                    ),
                    value: true,
                    onChanged: (bool value) {}),
                ToggleMenuFlyoutItem(
                    text: Text(
                      '-r',
                      style: getCommonTitleStyle(),
                    ),
                    value: true,
                    onChanged: (bool value) {}),
                const MenuFlyoutSeparator(),
                ToggleMenuFlyoutItem(
                    text: Text(
                      '-s',
                      style: getCommonTitleStyle(),
                    ),
                    value: true,
                    onChanged: (bool value) {}),
                ToggleMenuFlyoutItem(
                    text: Text(
                      '-d',
                      style: getCommonTitleStyle(),
                    ),
                    value: true,
                    onChanged: (bool value) {}),
              ]),
              MenuBarItem(title: '模拟指令', items: [
                MenuFlyoutItem(
                    text: Text(
                      '新建脚本',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () async {
                      DialogUtils.showCommonDialog<String>(
                          AndroidSimScriptDialog(),
                          title: "新建模拟脚本",
                          confirmText: "保存");
                    }),
              ]),
              MenuBarItem(title: '拉取和推送', items: [
                MenuFlyoutItem(
                    text: Text(
                      '拉取',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                const MenuFlyoutSeparator(),
                MenuFlyoutItem(
                    text: Text(
                      '推送',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
              ]),
              MenuBarItem(title: '其他', items: [
                MenuFlyoutItem(
                    text: Text(
                      '截屏',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                MenuFlyoutItem(
                    text: Text(
                      '录屏',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                const MenuFlyoutSeparator(),
                MenuFlyoutItem(
                    text: Text(
                      '进入fastboot',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                MenuFlyoutItem(
                    text: Text(
                      '进入recovery',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
                MenuFlyoutItem(
                    text: Text(
                      '重启手机',
                      style: getCommonTitleStyle(),
                    ),
                    onPressed: () {}),
              ]),
            ],
          ));
        }(),
        leading: IconButton(
          icon: const Icon(FluentIcons.accounts),
          onPressed: () => {},
        ),
      ),
    );
  }
}
