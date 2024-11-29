import 'package:flutter/material.dart';

class HoverWidget extends StatefulWidget {
  final Color hoverEnterColor;
  final Color hoverExitColor;

  ///是否需要鼠标划过改变颜色
  final bool isHoverChangeColor;

  final Widget child;

  final String? tipsMessage;

  HoverWidget(
      {Key? key,
      required this.hoverEnterColor,
      this.hoverExitColor = Colors.transparent,
      this.isHoverChangeColor = true,
      required this.child,
      this.tipsMessage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HoverWidgetState();
  }
}

class _HoverWidgetState extends State<HoverWidget> {
  late Color backgroundColor;
  late bool isHoverChangeColor;
  late String? tipsMessage;

  @override
  void initState() {
    super.initState();
    backgroundColor = widget.hoverExitColor;
    isHoverChangeColor = widget.isHoverChangeColor;
    tipsMessage = widget.tipsMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      textAlign: TextAlign.right,
      message: tipsMessage,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          if (!isHoverChangeColor) {
            return;
          }
          setState(() {
            backgroundColor = widget.hoverEnterColor;
          });
        },
        onExit: (event) {
          if (!isHoverChangeColor) {
            return;
          }
          setState(() {
            backgroundColor = widget.hoverExitColor;
          });
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Row(
            children: [Expanded(child: widget.child)],
          ),
        ),
      ),
    );
  }
}

///用于图标类按钮鼠标划过展示
class HoverIconWidget extends StatefulWidget {
  final Color hoverEnterColor;
  final Color hoverExitColor;

  ///是否需要鼠标划过改变颜色
  final bool isHoverChangeColor;

  final Widget child;

  final String? tipsMessage;

  final double iconSize;

  HoverIconWidget(
      {Key? key,
      required this.hoverEnterColor,
      this.hoverExitColor = Colors.transparent,
      this.isHoverChangeColor = true,
      this.iconSize = 15,
      required this.child,
      this.tipsMessage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HoverIconWidgetState();
  }
}

class _HoverIconWidgetState extends State<HoverIconWidget> {
  late Color backgroundColor;
  late bool isHoverChangeColor;
  late String? tipsMessage;
  late double iconSize;

  @override
  void initState() {
    super.initState();
    backgroundColor = widget.hoverExitColor;
    isHoverChangeColor = widget.isHoverChangeColor;
    tipsMessage = widget.tipsMessage;
    iconSize = widget.iconSize;
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tipsMessage,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          if (!isHoverChangeColor) {
            return;
          }
          setState(() {
            backgroundColor = widget.hoverEnterColor;
          });
        },
        onExit: (event) {
          if (!isHoverChangeColor) {
            return;
          }
          setState(() {
            backgroundColor = widget.hoverExitColor;
          });
        },
        child: Container(
          width: iconSize * 2,
          height: iconSize * 2,
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(iconSize * 2))),
          child: Row(
            children: [Expanded(child: widget.child)],
          ),
        ),
      ),
    );
  }
}
