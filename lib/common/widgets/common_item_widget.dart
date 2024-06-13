import 'package:flutter/material.dart';

/// @description: 通用的单个条目widget
/// @time 2024/6/3 17:13
/// @author lijie
/// @email jackyli706@gmail.com
class CommonItemWidget extends StatelessWidget {
  final String text;
  final Widget mainWidget;

  CommonItemWidget({Key? key, required this.text, required this.mainWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 150,
          alignment: Alignment.centerLeft,
          child: Text(text),
        ),
        Expanded(
            child: Card(
          elevation: 2,
          child: Container(
            padding: EdgeInsets.all(10),
            height: 60,
            child: mainWidget,
            alignment: Alignment.centerLeft,
          ),
        ))
      ],
    );
  }
}
