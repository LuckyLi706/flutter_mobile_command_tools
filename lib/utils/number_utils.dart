import 'dart:math';

/**
 * @Classname number_utils
 * @Date 2025/3/16 13:45
 * @Created by jacky
 * @Description 数字工具类
 */
class NumberUtils {
  /// 判断字符串是否为double或者int类型
  bool isNumber(String value) {
    double? numberDouble = double.tryParse(value);
    if (numberDouble == null) {
      int? numberInt = int.tryParse(value);
      if (numberInt == null) {
        return false;
      }
    }
    return true;
  }

  /// 安全字符串转int
  static int safeStrToInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }

  /// 安全字符串转double
  static double safeStrToDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0;
    }
  }

  /// 获取两个数之间的随机数
  static int getRandom(int min, int max) {
    if (min == max) {
      return min;
    }
    int random = min + Random().nextInt(max - min);
    return random;
  }
}
