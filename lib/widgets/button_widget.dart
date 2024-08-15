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
  final Function(int index) onTapIndex;

  PullDownWidget(this.dropDownListText, this.onTapIndex);

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      title: '',
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
