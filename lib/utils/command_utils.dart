import 'package:flutter_mobile_command_tools/command/adb_command.dart';

class CommandUtils {
  static final _adbCommand = new AdbCommand();

  static AdbCommand getAdbCommand() {
    return _adbCommand;
  }
}
