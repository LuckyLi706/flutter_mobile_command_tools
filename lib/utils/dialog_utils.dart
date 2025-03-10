import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/global.dart';

/**
 * @FileName : dialog_utils
 * @Author : lijie
 * @Time : 2025/3/10 18:58
 * @Description : 弹窗工具类
 */
class DialogUtils {
  /// 展示通用的弹窗
  static Future<T?> showCommonDialog<T>(Widget content,
      {String? title,
      bool isShowCancel = false,
      String cancelText = "取消",
      String confirmText = "确定"}) async {
    return await showDialog<T>(
      context: Global.scaffoldKey.currentContext!,
      builder: (context) => ContentDialog(
        title: title == null
            ? null
            : Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
        content: content,
        actions: [
          Button(
            child: Text(cancelText),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
            child: Text(confirmText),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
  }
}
