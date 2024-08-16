import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class ButtonWidget extends StatelessWidget {
  final String buttonText;
  final Function onTap;

  ButtonWidget(this.buttonText, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PushButton(
      child: Text(buttonText),
      controlSize: ControlSize.large,
      onPressed: () {
        onTap.call();
      },
    );
  }
}

class PullDownWidget extends StatelessWidget {
  final List<String> dropDownListText;
  final int selectIndex;
  final Function(int index) onTapIndex;

  PullDownWidget(this.dropDownListText, this.onTapIndex, this.selectIndex);

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      title: dropDownListText.length > 0 ? dropDownListText[selectIndex] : "",
      items: dropDownListText.map((text) {
        return MacosPulldownMenuItem(
          title: Text(text),
          onTap: () {
            onTapIndex.call(dropDownListText.indexOf(text));
          },
        );
      }).toList(),
    );
  }
}
