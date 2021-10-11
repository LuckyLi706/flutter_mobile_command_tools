import 'dart:io';

class PlatformUtils {
  static String getLineBreak() {
    if (Platform.isWindows) {
      return "\r\n";
    } else {
      return "\n";
    }
  }

  ///windows和linux系统的命令行指令不一样
  static Future<ProcessResult> runCommand(String commandStr,
      {bool runInShell = true, String? workDirectory}) {
    if (Platform.isMacOS || Platform.isLinux) {
      String executable = commandStr.split(" ")[0];
      List<String> arguments =
          commandStr.replaceFirst(executable, "").trim().split(" ");
      return Process.run(executable, arguments,
          runInShell: runInShell, workingDirectory: workDirectory);
    } else {
      return Process.run(commandStr, [],
          runInShell: runInShell, workingDirectory: workDirectory);
    }
  }

  static String getSeparator() {
    if (Platform.isWindows) {
      return r"\";
    }
    return r"/";
  }
}
