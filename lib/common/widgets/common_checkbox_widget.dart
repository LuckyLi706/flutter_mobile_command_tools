import 'package:flutter/material.dart';

/// @description: 通用的选择框
/// @time 2024/6/4 14:53
/// @author lijie
/// @email jackyli706@gmail.com
class CommonCheckBoxWidget extends StatelessWidget {
  const CommonCheckBoxWidget(
    this.text, {
    super.key,
    required this.onCheck,
    required this.isCheck,
  });

  final String text;
  final Function(bool value) onCheck;
  final bool isCheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: const BoxDecoration(
      //   borderRadius: BorderRadius.all(Radius.circular(5)),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isCheck,
            onChanged: (value) {
              onCheck(value ?? false);
            },
            shape: const CircleBorder(), //这里就是实现圆形的设置
          ),
          Text(
            text,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
