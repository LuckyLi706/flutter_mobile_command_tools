import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/base/base_state_page.dart';
import 'package:flutter_mobile_command_tools/common/widgets/common_checkbox_widget.dart';
import 'package:flutter_mobile_command_tools/common/widgets/common_item_widget.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/generated/l10n.dart';
import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/notifier/global/locale_change_notifier.dart';
import 'package:flutter_mobile_command_tools/notifier/global/theme_change_notifier.dart';
import 'package:flutter_mobile_command_tools/utils/sp_util.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// @description: 设置页面
/// @time 2024/5/23 16:06
/// @author lijie
/// @email jackyli706@gmail.com
class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends BaseStatePage<SettingPage> {
  final ThemeChangeNotifier themeChangeNotifier =
      Provider.of<ThemeChangeNotifier>(Constants.navigatorKey.currentContext!);
  final LocaleChangeNotifier localeChangeNotifier =
      Provider.of<LocaleChangeNotifier>(Constants.navigatorKey.currentContext!);

  @override
  Widget buildMainWidget() {
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CommonItemWidget(
                text: S.of(context).change_theme,
                mainWidget: changeThemeWidget()),
            CommonItemWidget(
                text: S.of(context).change_language,
                mainWidget: changeLanguageWidget()),
            CommonItemWidget(text: 'adb', mainWidget: inputAdbPathWidget())
          ],
        ),
      ),
    );
  }

  List<Color> allThemeColors = [];
  List<String> allLanguage = [];

  @override
  void initState() {
    super.initState();

    allThemeColors = themeChangeNotifier.colorLList;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      allLanguage.add(S.of(context).chinese);
      allLanguage.add(S.of(context).english);

      localeChangeNotifier.setLanguage(SpUtil.getInstance().getLocaleIndex());
    });
  }

  ///切换主题的widget
  Widget changeThemeWidget() {
    return Wrap(
      children: allThemeColors
          .map((e) => GestureDetector(
                child: Container(
                    width: 40,
                    height: 40,
                    color: e,
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(bottom: 5, right: 5),
                    child: Visibility(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      visible: SpUtil.getInstance().getThemeIndex() ==
                          allThemeColors.indexOf(e),
                    )),
                onTap: () {
                  SpUtil.getInstance().setThemeIndex(allThemeColors.indexOf(e));
                  themeChangeNotifier.themeData = themeChangeNotifier
                      .themeDataList[allThemeColors.indexOf(e)];
                },
              ))
          .toList(),
      runSpacing: 10,
      spacing: 10,
    );
  }

  ///切换语言的widget
  Widget changeLanguageWidget() {
    allLanguage.clear();
    allLanguage.add(S.of(context).chinese);
    allLanguage.add(S.of(context).english);
    return Wrap(
      children: allLanguage.map((e) {
        return CommonCheckBoxWidget(e, onCheck: (value) {
          if (value) {
            SpUtil.getInstance().setLocaleIndex(allLanguage.indexOf(e));
            localeChangeNotifier.setLanguage(allLanguage.indexOf(e));
          }
        },
            isCheck: SpUtil.getInstance().getLocaleIndex() ==
                allLanguage.indexOf(e));
      }).toList(),
      runSpacing: 10,
      spacing: 10,
    );
  }

  ///adb
  Widget inputAdbPathWidget() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: TextEditingController(text: Global.adbPath),
        )),
        TextButton(
          onPressed: () async {
            await _selectFile();
          },
          child: Text(
            '选择路径',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  /// 展示选择文件的弹窗
  Future<String?> _selectFile({List<String>? extensions}) async {
    final typeGroup = XTypeGroup(
      //label: 'images',
      extensions: extensions,
    );
    final files = await FileSelectorPlatform.instance
        .openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isNotEmpty) {
      return files[0].path;
    }
    return null;
  }

  @override
  String? appBarTitle() {
    return S.of(context).setting;
  }
}
