import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/utils/sp_util.dart';

/// @description: 主题切换
/// @time 2024/5/23 14:48
/// @author lijie
/// @email jackyli706@gmail.com
class ThemeChangeNotifier extends ChangeNotifier {
  List<ThemeData> themeDataList = [
    ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.red),
        checkboxTheme: CheckboxThemeData(
          fillColor:
              MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.red;
            }
            return Colors.white;
          }),
        ),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
// If the button is pressed, return green, otherwise blue
          if (states.contains(MaterialState.pressed)) {
            return Colors.red;

            ///扩展String函数
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.red;

            ///扩展String函数
          }
          return Colors.red.withOpacity(0.5);

          ///扩展String函数
        })))),
    ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.orange),
        checkboxTheme: CheckboxThemeData(
          fillColor:
              MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange;
            }
            return Colors.white;
          }),
        ),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
// If the button is pressed, return green, otherwise blue
          if (states.contains(MaterialState.pressed)) {
            return Colors.orange;

            ///扩展String函数
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.orange;

            ///扩展String函数
          }
          return Colors.orange.withOpacity(0.5);

          ///扩展String函数
        })))),
    ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.yellow),
        checkboxTheme: CheckboxThemeData(
          fillColor:
              MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.yellow;
            }
            return Colors.white;
          }),
        ),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
// If the button is pressed, return green, otherwise blue
          if (states.contains(MaterialState.pressed)) {
            return Colors.yellow;

            ///扩展String函数
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.yellow;

            ///扩展String函数
          }
          return Colors.yellow.withOpacity(0.5);

          ///扩展String函数
        })))),
    ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.green),
        checkboxTheme: CheckboxThemeData(
          fillColor:
              MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.green;
            }
            return Colors.white;
          }),
        ),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
// If the button is pressed, return green, otherwise blue
          if (states.contains(MaterialState.pressed)) {
            return Colors.green;

            ///扩展String函数
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.green;

            ///扩展String函数
          }
          return Colors.green.withOpacity(0.5);

          ///扩展String函数
        })))),
    ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.blue),
        checkboxTheme: CheckboxThemeData(
          fillColor:
              MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue;
            }
            return Colors.white;
          }),
        ),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.blue;

            ///扩展String函数
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.blue;

            ///扩展String函数
          }
          return Colors.yellow.withOpacity(0.5);

          ///扩展String函数
        })))),
    ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.purple),
        checkboxTheme: CheckboxThemeData(
          fillColor:
              MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.purple;
            }
            return Colors.white;
          }),
        ),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
// If the button is pressed, return green, otherwise blue
          if (states.contains(MaterialState.pressed)) {
            return Colors.purple;

            ///扩展String函数
          } else if (states.contains(MaterialState.hovered)) {
            return Colors.purple;

            ///扩展String函数
          }
          return Colors.purple.withOpacity(0.5);

          ///扩展String函数
        })))),
  ];

  late List<Color> colorLList = List.generate(themeDataList.length,
      (index) => themeDataList[index].appBarTheme.backgroundColor!);

  late ThemeData _themeData =
      themeDataList[SpUtil.getInstance().getThemeIndex()];

  ThemeData get themeData => _themeData;

  set themeData(ThemeData value) {
    _themeData = value;
    notifyListeners();
  }
}
