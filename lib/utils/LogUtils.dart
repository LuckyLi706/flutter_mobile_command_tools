class LogUtils {
  ///Release：const bool.fromEnvironment("dart.vm.product") = true；
  /// Debug：assert(() { ...; return true; });断言语句会被执行；
  /// Profile：上面的两种情况均不会发生。
  static printLog(log) {
    const bool inProduction = const bool.fromEnvironment("dart.vm.product");
    if (!inProduction) {
      print(log);
    }
  }
}
