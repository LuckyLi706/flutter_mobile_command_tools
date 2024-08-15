import 'package:flutter/material.dart';

class TextFieldModel {
  late ScrollController _scrollController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  TextFieldModel(
      this._scrollController, this._textEditingController, this._focusNode);

  ScrollController get scrollController => _scrollController;

  set scrollController(ScrollController value) {
    _scrollController = value;
  }

  TextEditingController get textEditingController => _textEditingController;

  FocusNode get focusNode => _focusNode;

  set focusNode(FocusNode value) {
    _focusNode = value;
  }

  set textEditingController(TextEditingController value) {
    _textEditingController = value;
  }
}
