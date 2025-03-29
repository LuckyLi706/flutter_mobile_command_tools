import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/base/base_dialog.dart';
import 'package:flutter_mobile_command_tools/enum/file_name_type.dart';
import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/notifier/dialog/android_input_notifier.dart';
import 'package:flutter_mobile_command_tools/utils/file_utils.dart';
import 'package:flutter_mobile_command_tools/utils/platform_utils.dart';
import 'package:flutter_mobile_command_tools/utils/toast_utils.dart';
import 'package:flutter_mobile_command_tools/widgets/dialog/android_sim_script_dialog.dart';
import 'package:provider/provider.dart';

/**
 * @FileName : dialog_utils
 * @Author : lijie
 * @Time : 2025/3/10 18:58
 * @Description : 弹窗工具类
 */
class DialogUtils {
  /// 展示通用文本的弹窗
  static Future<T?> showTextDialog<T>({
    required List<String> contents,
    List<int> colorChangeIndex = const [],
    List<Color> contentChangeColor = const [],
    String title = "",
    Function()? onConfirm,
    Function? onCancel,
  }) async {
    List<Color> contentColors = [];
    if (colorChangeIndex.isEmpty || contentChangeColor.isEmpty) {
      for (int i = 0; i < contents.length; i++) {
        contentColors[i] = Colors.black;
      }
    } else {
      for (int i = 0; i < contents.length; i++) {
        if (colorChangeIndex.contains(i)) {
          try {
            contentColors.add(contentChangeColor[colorChangeIndex.indexOf(i)]);
          } catch (e) {
            contentColors.add(Colors.black);
          }
        } else {
          contentColors.add(Colors.black);
        }
      }
    }
    return await showDialog<T>(
        context: Global.scaffoldKey.currentContext!,
        builder: (context) => BaseConfirmCancelDialog(
            dialogTitle: title,
            onCancel: onCancel,
            onConfirm: onConfirm,
            contentWidget: Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  RichText(
                      text: TextSpan(
                          children: contents.map((String content) {
                    return TextSpan(
                        text: content,
                        style: TextStyle(
                            color: contentColors[contents.indexOf(content)],
                            fontSize: 16));
                  }).toList()))
                ],
              ),
            )));
  }

  /// 展示输入类型的通用弹窗
  static Future<T?> showInputDialog<T>({
    required String title,
    required FileNameType fileNameType,
    required String confirmText,
    Function(String deviceName)? onConfirm,
    Function? onCancel,
  }) async {
    AndroidInputNotifier androidInputNotifier = new AndroidInputNotifier();

    String filePath = await FileUtils.getConfigFileByName(fileNameType);
    List<String> contentList = await FileUtils.readFileByLine(filePath);
    if (contentList.isEmpty) {
      contentList.add(' ');
    }
    androidInputNotifier.connectDeviceList = contentList;

    return await showDialog<T>(
        context: Global.scaffoldKey.currentContext!,
        builder: (context) => BaseConfirmCancelDialog(
            dialogTitle: title,
            onCancel: onCancel,
            onConfirm: () {
              Navigator.pop(context, androidInputNotifier.connectDevice);
            },
            confirmText: confirmText,
            contentWidget: ChangeNotifierProvider<AndroidInputNotifier>(
              create: (context) => androidInputNotifier,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Expanded(child: Consumer<AndroidInputNotifier>(
                        builder: (context, value, child) {
                      return EditableComboBox<String>(
                        value: value.connectDevice,
                        items: value.connectDeviceList
                            .map<ComboBoxItem<String>>((e) {
                          return ComboBoxItem<String>(
                            child: Text('$e'),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (deviceName) {
                          value.connectDevice = deviceName ?? '';
                        },
                        onFieldSubmitted: (String text) {
                          value.connectDevice = text;
                          return text;
                        },
                      );
                    })),
                    SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                        child: Text('保存记录'),
                        onPressed: () {
                          if (contentList.contains(' ') ||
                              contentList.contains('')) {
                            contentList.remove(' ');
                            contentList.remove('');
                          }
                          if (contentList
                              .contains(androidInputNotifier.connectDevice)) {
                            showToast(message: '当前记录已存在', title: '');
                            return;
                          }
                          contentList.add(androidInputNotifier.connectDevice);
                          FileUtils.writeFile(
                              contentList.join(PlatformUtils.getLineBreak()),
                              filePath);
                          showToast(message: '保存记录成功', title: '');
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                        child: Text('删除记录'),
                        onPressed: () {
                          if (androidInputNotifier.connectDevice == ' ' ||
                              androidInputNotifier.connectDevice == ' ') {
                            showToast(message: '删除记录不能为空', title: '');
                            return;
                          }
                          contentList
                              .remove(androidInputNotifier.connectDevice);
                          androidInputNotifier.connectDeviceList = contentList;
                          FileUtils.writeFile(
                              contentList.join(PlatformUtils.getLineBreak()),
                              filePath);
                          showToast(message: '删除记录成功', title: '');
                        })
                  ],
                ),
              ),
            )));
  }

  /// 展示新建脚本弹窗
  static Future<T?> showNewOperationScriptDialog<T>() async {
    GlobalKey<AndroidSimScriptDialogState> globalKey = GlobalKey();

    return await showDialog<T>(
        context: Global.scaffoldKey.currentContext!,
        builder: (context) => BaseConfirmCancelDialog(
              dialogTitle: '新建脚本',
              onConfirm: () {
                if (globalKey.currentState != null) {
                  if (globalKey.currentState!.simOperationModel.simOperationList
                      .isEmpty) {
                    showToast(message: '请先加指令添加到指令列表中', title: '保存失败');
                  } else {
                    FileUtils.writeSimOperationFile(
                        globalKey.currentState!.simOperationModel,
                        globalKey.currentState?.fileName);
                    showToast(
                        message: '',
                        title: '保存成功',
                        severity: InfoBarSeverity.success);
                    Navigator.pop(context);
                  }
                }
              },
              contentWidget: AndroidSimScriptDialog(globalKey),
            ));
  }
}
