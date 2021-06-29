import 'dart:convert';
import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/command/Command.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/utils/FileUtils.dart';
import 'package:flutter_mobile_command_tools/utils/InitUtils.dart';

var _width = 0.0;
var _height = 0.0;
var _settings = {};

void main() {
  runApp(new MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    getWidthHeight(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Constants.APP_TITLE_NAME),
          actions: [
            new IconButton(
                onPressed: () async {
                  //执行函数
                  //showSettingDialog(context);

                  //showPickerDialog(context);

                  showPickerDialog(context);
                },
                icon: new Icon(Icons.settings))
          ],
        ),
        body: new Container(
          child: new Row(
            children: [
              new Container(
                width: _width * 0.7,
                height: _height * 0.9,
                child: Stack(
                  alignment: Alignment.topLeft,
                  //fit: StackFit.expand, //未定位widget占满Stack整个空间
                  children: <Widget>[
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 18.0,
                      child: Text("日志展示："),
                    ),
                    Positioned(
                      top: 55.0,
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: new Scrollbar(
                          isAlwaysShown: true,
                          child: SingleChildScrollView(
                            child: new LeftPanel(globalKey),
                            scrollDirection: Axis.vertical,
                          )),
                    )
                  ],
                ),
                padding: EdgeInsets.all(10),
              ),
              new Container(
                color: Color.fromARGB(200, 0, 255, 255),
                width: _width * 0.3,
                child: new RightPanel(),
              )
            ],
          ),
        ));
  }
}

String text = "";

/// 左边展示的面板
class LeftPanel extends StatefulWidget {
  final Key key;

  LeftPanel(this.key);

  @override
  LeftPanelState createState() {
    return new LeftPanelState();
  }
}

TextEditingController _textEditingController =
    new TextEditingController(text: text);

GlobalKey<LeftPanelState> globalKey = GlobalKey();

class LeftPanelState extends State<LeftPanel> {
  void updateText(String updateText) {
    setState(() {
      text = text + "\n" + updateText;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FileUtils.readSetting().then((value) {
      Map<String, dynamic> map = jsonDecode(value);
      Constants.adbPath = map['adb'];
    });

    InitUtils.initDesktop();
  }

  @override
  Widget build(BuildContext context) {
    // return new TextField(
    //   controller: _textEditingController,
    //   keyboardType: TextInputType.multiline,
    //   maxLines: null, //不限制行数
    //   enabled: false,
    // );

    return new Text(
      text,
      maxLines: null,
    );
  }
}

///右边展示的面板
class RightPanel extends StatefulWidget {
  @override
  RightPanelState createState() => RightPanelState();
}

class RightPanelState extends State<RightPanel>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          tabs: [
            Tab(
              text: "Android",
            ),
            Tab(
              text: "IOS",
            ),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          AndroidRightPanel(),
          Center(child: Text('自行车')),
        ],
        controller: tabController,
      ),
    );
  }
}

class AndroidRightPanel extends StatefulWidget {
  @override
  AndroidRightPanelState createState() => AndroidRightPanelState();
}

late CommandResult result;
List<DropdownMenuItem<String>> items = [];

ScrollController scrollController = new ScrollController();
final AndroidCommand command = new AndroidCommand();

class AndroidRightPanelState extends State<AndroidRightPanel> {
  TextEditingController _packageController = new TextEditingController();

  void updateText(List<String> resultList) {
    setState(() {
      items.clear();
      Constants.currentDevice = resultList[0];
      resultList.forEach((element) {
        items.add(new DropdownMenuItem(child: new Text(element)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: new Column(children: [
          new Row(children: [new Text("基本操作：")]),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new TextButton(
                  onPressed: () {
                    command.execCommand([Constants.ADB_CONNECT_DEVICES]).then(
                        (value) {
                      result = command.dealWithData(
                          Constants.ADB_CONNECT_DEVICES, value);
                      if (result.mError) {
                        globalKey.currentState?.updateText(result.mResult);
                      } else {
                        updateText(result.mResult);
                      }
                    }).catchError((e) {
                      globalKey.currentState?.updateText(e.toString());
                    });
                  },
                  child: new Text("获取设备")),
              DropdownButton<String>(
                value: items.length > 0 ? items[0].value : "",
                onChanged: (String? newValue) {
                  setState(() {
                    Constants.currentDevice = newValue == null ? "" : newValue;
                    //print(dropdownValue);
                  });
                },
                items: items,
              ),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new TextButton(
                  onPressed: () {
                    command
                        .execCommand(Constants.ADB_GET_PACKAGE.split(" "))
                        .then((value) {
                      result = command.dealWithData(
                          Constants.ADB_GET_PACKAGE, value);
                      if (result.mError) {
                        globalKey.currentState?.updateText(result.mResult);
                      } else {
                        _packageController.text = result.mResult;
                      }
                    }).catchError((e) {
                      globalKey.currentState?.updateText(e.toString());
                    });
                  },
                  child: new Text("获取包名")),
              new Expanded(
                  child: new TextField(
                controller: _packageController,
                enabled: false,
                maxLength: 20,
              ))
            ],
          ),
          new Row(children: [
            new TextButton(
                onPressed: () {
                  command
                      .execCommand(Constants.ADB_SCREEN_SHOT.split(" "))
                      .then((value) {
                    result =
                        command.dealWithData(Constants.ADB_SCREEN_SHOT, value);
                    if (!result.mError) {
                      command
                          .execCommand(
                              Constants.ADB_PULL_SCREEN_SHOT.split(" "),
                              workingDirectory: Constants.desktopPath)
                          .then((value) {
                        result = command.dealWithData(
                            Constants.ADB_PULL_SCREEN_SHOT, value);
                        globalKey.currentState?.updateText(result.mResult);
                      });
                    }
                  }).catchError((e) {
                    globalKey.currentState?.updateText(e.toString());
                  });
                },
                child: new Text("截屏"))
          ])
        ]));
  }
}

final TextEditingController _controller =
    new TextEditingController(text: Constants.adbPath);

//SettingModel settingModel=new SettingModel("");

showSettingDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // return new Scaffold(
        //   appBar: new AppBar(
        //     title: new Text(Constants.APP_TITLE_NAME),
        //   ),
        //   body:
        return UnconstrainedBox(
          //在Dialog的外层添加一层UnconstrainedBox
          //constrainedAxis: Axis.vertical,
          child: SizedBox(
            //再用SizeBox指定宽度new Dialog(
            child: new AlertDialog(
              scrollable: true,
              actions: [
                TextButton(
                  child: Text('确定'),
                  onPressed: () {
                    //settingModel.adb = _controller.text;
                    _settings['adb'] = _controller.text;
                    FileUtils.writeSetting(_settings);
                    Navigator.of(context).pop();
                  },
                )
              ],
              title: new Text("设置", style: new TextStyle(fontSize: 20)),
              content: new Center(
                  child: new Container(
                      //color: Color.fromARGB(255, 250, 255, 0),
                      width: 0.3 * _width,
                      height: 0.3 * _height,
                      child: new SingleChildScrollView(
                        child: new Column(
                          children: [
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Expanded(
                                    child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    // labelText: '表单label',
                                    // labelStyle: TextStyle(
                                    //   color: Colors.pink,
                                    //   fontSize: 12,
                                    // ),
                                    helperText: 'adb目录',
                                    hintText: 'adb目录...',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(height: 10),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // new Text("adb目录"),
                                // SizedBox(width: 10),
                                new Expanded(
                                    child: TextField(
                                  decoration: InputDecoration(
                                    // labelText: '表单label',
                                    // labelStyle: TextStyle(
                                    //   color: Colors.pink,
                                    //   fontSize: 12,
                                    // ),
                                    helperText: '',
                                    hintText: 'Placeholder...',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(height: 10),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // new Text("adb目录"),
                                // SizedBox(width: 10),
                                new Expanded(
                                    child: TextField(
                                  decoration: InputDecoration(
                                    // labelText: '表单label',
                                    // labelStyle: TextStyle(
                                    //   color: Colors.pink,
                                    //   fontSize: 12,
                                    // ),
                                    helperText: 'helperText',
                                    hintText: 'Placeholder...',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ))),
            ),
            // return new Center(
            //     child: new Container(
            //   width: _width / 3,
            //   height: _height / 3,
            //   color: Color.fromARGB(255, 255, 255, 255),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [new Scaffold(body: Text("222"))],
            //       )
            //     ],
            //   ),
            // ));
          ),
        );
      });
}

showPickerDialog(BuildContext context) async {
  //Directory.current;
  // String? path = await FilesystemPicker.open(
  //   title: 'Save to folder',
  //   context: context,
  //   rootDirectory: Directory(r"/"),
  //   fsType: FilesystemType.folder,
  //   pickText: 'Save file to this folder',
  //   folderIconColor: Colors.teal,
  // );
  // print(path);

  final typeGroup = XTypeGroup(
    label: 'images',
    extensions: ['exe'],
  );
  final files = await FileSelectorPlatform.instance
      .openFiles(acceptedTypeGroups: [typeGroup]);
  final file = files[0];
  final fileName = file.name;
  final filePath = file.path;
  print(filePath + "," + fileName);
  // await showDialog(
  //   context: context,
  //   builder: (context) => ImageDisplay(fileName, filePath),
  // );
  //final file = await openFile(acceptedTypeGroups: [typeGroup]);
}

getWidthHeight(BuildContext context) {
  final size = MediaQuery.of(context).size;
  _width = size.width;
  _height = size.height;
}
