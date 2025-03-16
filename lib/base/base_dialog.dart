import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/utils/window_utils.dart';

/**
 * @Classname base_dialog
 * @Date 2025/3/14 22:54
 * @Created by jacky
 * @Description 所有弹窗的基类
 */

/// 确认、取消按钮弹窗基类
class BaseConfirmCancelDialog extends StatelessWidget {
  final Widget contentWidget;

  /// 弹窗背景色
  final Color dialogBackgroundColor;

  /// 弹窗的圆角
  final double dialogRadius;

  ///  是否展示标题
  final bool isShowTitle;

  /// 弹窗标题
  final String dialogTitle;

  /// 弹窗长度
  final double dialogWidth = WindowUtils.getWindowWidth() / 3;

  /// 点击确认按钮
  final Function? onConfirm;

  /// 点击取消按钮
  final Function? onCancel;

  /// 是否只展示确认按钮
  final bool isOnlyConfirm;

  /// 确认按钮文本
  final String confirmText;

  /// 取消按钮文本
  final String cancelText;

  BaseConfirmCancelDialog({
    Key? key,
    required this.contentWidget,
    this.onConfirm,
    this.onCancel,
    this.isOnlyConfirm = false,
    this.confirmText = "确认",
    this.cancelText = "取消",
    this.dialogBackgroundColor = Colors.white,
    this.dialogRadius = 12,
    this.isShowTitle = true,
    this.dialogTitle = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      dialogTitle,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  )
                ],
              ),
              visible: isShowTitle && dialogTitle.length > 0,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: contentWidget,
            ),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Button(
                    child: Text(cancelText),
                    onPressed: () {
                      Navigator.pop(context);
                      onCancel?.call();
                    },
                  ),
                  FilledButton(
                    child: Text(confirmText),
                    onPressed: () {
                      if (onConfirm == null) {
                        Navigator.pop(context);
                      }
                      onConfirm?.call();
                    },
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
            )
          ],
        ),
        width: dialogWidth,
        decoration: BoxDecoration(
            color: dialogBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(dialogRadius))),
      ),
    );
  }
}
