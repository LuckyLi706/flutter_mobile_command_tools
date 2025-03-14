import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../../notifier/panel/android_panel_notifier.dart';

/**
 * @FileName : android_disconnect_device_dialog
 * @Author : lijie
 * @Time : 2025/3/11 14:26
 * @Description : 安卓断开连接设备弹窗
 */
class AndroidDisconnectDeviceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(children: [
            TextSpan(text: '确定断开连接的设备', style: TextStyle(color: Colors.black)),
            TextSpan(
                text: context.read<AndroidPanelNotifier>().deviceList[
                    context.read<AndroidPanelNotifier>().deviceIndex],
                style: TextStyle(color: Colors.red)),
            TextSpan(text: '嘛？', style: TextStyle(color: Colors.black)),
          ]))
        ],
      ),
    );
  }
}
