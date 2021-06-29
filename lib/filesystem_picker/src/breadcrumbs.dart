import 'package:flutter/material.dart';
import 'listview_extensions.dart';

/// Path element description class for breadcrumbs
class BreadcrumbItem<T> {
  /// Item text
  final String text;

  /// Item related data
  final T? data;

  /// Called when an item is selected
  final ValueChanged<T>? onSelect;

  /// Creates an item of breadcrumbs
  BreadcrumbItem({
    required this.text,
    this.data,
    this.onSelect,
  });
}

/// Scrolling horizontal breadcrumbs with `Icons.chevron_right` separator and fade on the right.
class Breadcrumbs<T> extends StatelessWidget {
  /// List of items of breadcrumbs
  final List<BreadcrumbItem<T?>> items;

  /// Height of the breadcrumbs panel
  final double height;

  /// List item text color
  final Color? textColor;

  /// Called when an item is selected
  final ValueChanged<T?>? onSelect;

  final ScrollController _scrollController = ScrollController();

  Breadcrumbs({
    Key? key,
    required this.items,
    this.height = 50,
    this.textColor,
    this.onSelect,
  }) : super(key: key);

  _scrollToEnd() async {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());

    final Color? defaultTextColor = Theme.of(context).textTheme.button!.color;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment(0.7, 0.5),
          end: Alignment.centerRight,
          colors: <Color>[Colors.white, Colors.transparent],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Container(
        alignment: Alignment.topLeft,
        height: height,
        child: ListViewExtended.separatedWithHeaderFooter(
          controller: _scrollController,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return ButtonTheme(
              minWidth: 48,
              padding: EdgeInsets.symmetric(
                      vertical: ButtonTheme.of(context).padding.vertical) +
                  const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                child: Text(
                  items[index].text,
                  style: TextStyle(
                    color: (index == (items.length - 1))
                        ? (textColor ?? defaultTextColor)
                        : (textColor ?? defaultTextColor)!.withOpacity(0.75),
                  ),
                ),
                onPressed: () {
                  items[index].onSelect?.call(items[index].data);
                  onSelect?.call(items[index].data);
                },
              ),
            );
          },
          separatorBuilder: (_, __) => Container(
            alignment: Alignment.center,
            child: Icon(
              Icons.chevron_right,
              color: (textColor ?? defaultTextColor)!.withOpacity(0.45),
            ),
          ),
          headerBuilder: (_) =>
              SizedBox(width: ButtonTheme.of(context).padding.horizontal - 8),
          footerBuilder: (_) => const SizedBox(width: 70),
        ),
      ),
    );
  }
}
