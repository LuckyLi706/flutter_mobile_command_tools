import 'package:fluent_ui/fluent_ui.dart';

import '../global.dart';

/**
 * @Classname toast_utils
 * @Date 2025/3/15 16:39
 * @Created by jacky
 * @Description 吐司
 */
Future<void> showToast({
  required String message,
  required String title,
  InfoBarSeverity severity = InfoBarSeverity.info,
}) async {
  await displayInfoBar(Global.scaffoldKey.currentContext!,
      builder: (context, close) {
    return InfoBar(
      title: Text(title),
      content: Text(message),
      // action: IconButton(
      //   icon: const Icon(FluentIcons.clear),
      //   onPressed: close,
      // ),
      severity: severity,
    );
  });
}
