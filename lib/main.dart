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
String _showLogText = ""; //展示日志的信息
late CommandResult result; //命令的结果
List<DropdownMenuItem<String>> connectDeviceDdmi = []; //获取设备下拉框的列表
List<String> currentAllDevice = []; //当前所有连接的设备
List<DropdownMenuItem<String>> wireLessDeviceDdmi = []; //下拉框的列表

List<DropdownMenuItem<String>> pullDdmi = []; //下拉框的列表
final AndroidCommand command = new AndroidCommand(); //命令信息

late String currentWirelessDevice; //当前需要连接的无线设备
String currentPullPath = ""; //当前pull文件的路径
String currentPullFile = ""; //当前pull文件的路径

void main() {
  InitUtils.init();
  _initAllWireLessDevice();
  runApp(new MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _getWidthHeight(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Constants.APP_TITLE_NAME),
          actions: [
            new IconButton(
                onPressed: () async {
                  adbController.text = Constants.adbPath;
                  print(Constants.adbPath);
                  //执行函数
                  //showSettingDialog(context);
                  // String? path=await _selectFile(context,extensions: ["png"]);
                  // print(path);
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
                      top: 20.0,
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: new Scrollbar(
                          isAlwaysShown: true,
                          child: SingleChildScrollView(
                            child: new LeftPanel(),
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

/// 左边展示的面板
class LeftPanel extends StatefulWidget {
  @override
  LeftPanelState createState() {
    return new LeftPanelState();
  }
}

TextEditingController _logTextController = new TextEditingController();

class LeftPanelState extends State<LeftPanel> {
  @override
  Widget build(BuildContext context) {
    return new TextField(
      controller: _logTextController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      //不限制行数
      enabled: false,
      autofocus: false,
      decoration: InputDecoration(
        labelText: "日志信息",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide()),
      ),
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

ScrollController scrollController = new ScrollController();

class AndroidRightPanelState extends State<AndroidRightPanel> {
  TextEditingController _packageController = new TextEditingController();
  FocusNode _wirelessFocus = FocusNode(); //得到焦点
  FocusNode _pushFocus = FocusNode(); //得到焦点
  FocusNode _pullFocus = FocusNode(); //得到焦点
  bool? _checkWireless = false; //无线连接的复选框
  bool? _checkPush = false; //推送的复选框

  void updateConnectDevice(List<String> resultList) {
    setState(() {
      connectDeviceDdmi.clear();
      if (resultList.length > 0) {
        Constants.currentDevice = resultList[0];
        resultList.toSet().forEach((element) {
          connectDeviceDdmi.add(new DropdownMenuItem(
            child: new Text(
              element,
              style: _dropDownTextStyle(),
            ),
            value: element,
          ));
        });
      } else {
        Constants.currentDevice = "";
      }
    });
  }

  void updatePull(List<String> fileList) {
    setState(() {
      pullDdmi.clear();
      if (fileList.length > 0) {
        currentPullFile = fileList[0];
        fileList.toSet().forEach((element) {
          pullDdmi.add(new DropdownMenuItem(
            child: new Text(
              element,
              style: _dropDownTextStyle(),
            ),
            value: element,
          ));
        });
      } else {
        currentPullFile = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 10,
              ),
              new Row(children: [new Text("基本操作：")]),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            command.execCommand(
                                [Constants.ADB_CONNECT_DEVICES]).then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_CONNECT_DEVICES, value);
                              if (result.mError) {
                                updateConnectDevice([]);
                                _showLog(result.mResult);
                              } else {
                                currentAllDevice = result.mResult;
                                updateConnectDevice(result.mResult);
                              }
                            }).catchError((e) {
                              updateConnectDevice([]);
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("获取设备"))),
                  Expanded(
                      child: DropdownButton<String>(
                    value: Constants.currentDevice,
                    onChanged: (String? newValue) {
                      setState(() {
                        Constants.currentDevice =
                            newValue == null ? "" : newValue;
                      });
                    },
                    items: connectDeviceDdmi,
                  )),
                ],
              ),
              new Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            command
                                .execCommand(
                                    Constants.ADB_GET_PACKAGE.split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_GET_PACKAGE, value);
                              if (result.mError) {
                                _showLog(result.mResult);
                              } else {
                                _packageController.text = result.mResult;
                              }
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("获取包名"))),
                  Expanded(
                      child: new TextField(
                    controller: _packageController,
                    enabled: false,
                    maxLength: 20,
                  ))
                ],
              ),
              new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          command
                              .execCommand(Constants.ADB_SCREEN_SHOT.split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_SCREEN_SHOT, value);
                            if (!result.mError) {
                              command
                                  .execCommand(
                                      Constants.ADB_PULL_SCREEN_SHOT.split(" "),
                                      workingDirectory: Constants.desktopPath)
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_SCREEN_SHOT, value);
                                _showLog(result.mResult);
                              });
                            }
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("截屏"))),
                Expanded(
                    child:
                        new TextButton(onPressed: () {}, child: new Text("录屏")))
              ]),
              new Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String? apkPath =
                                await _selectFile(context, extensions: ["apk"]);
                            if (apkPath == null) {
                              _showLog("未选择apk");
                              return;
                            }
                            command.execCommand([
                              Constants.ADB_INSTALL_APK,
                              apkPath
                            ]).then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_INSTALL_APK, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("安装apk"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            if (_packageController.text.isEmpty) {
                              _showLog("请先获取包名");
                              return;
                            }
                            command.execCommand([
                              Constants.ADB_UNINSTALL_APK,
                              _packageController.text
                            ]).then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_UNINSTALL_APK, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("卸载apk"))),
                ],
              ),
              new Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            command.execCommand([
                              Constants.ADB_REBOOT,
                            ]).then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_REBOOT, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("重启"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            command
                                .execCommand(
                                    Constants.ADB_REBOOT_BOOTLOADER.split("\n"))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_REBOOT_BOOTLOADER, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("重启到fastboot"))),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              new Row(children: [new Text("连接和断开：")]),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: new TextButton(
                          /**
                         * 无线连接设备
                         * 真机：
                         * 复选框没有选择，判断当前获取的设备是否存在，存在尝试去获取他的ip，获取失败，要求去手动收入ip和port
                         * 复选框选择了，断开转发，然后再去连接
                         *
                         * 其他模拟器：
                         * 复选框没有选择，使用默认的ip和port去连接
                         * 复选框选择了，直接去连接
                         */
                          onPressed: () async {
                            String deviceIp =
                                _getDeviceIp(currentWirelessDevice);
                            if (deviceIp == "0") {
                              if (_checkWireless == true) {
                                command
                                    .execCommand(
                                        Constants.ADB_FORWARD_PORT.split(" "))
                                    .then((value) {
                                  result = command.dealWithData(
                                      Constants.ADB_FORWARD_PORT, value);
                                  if (result.mError) {
                                    _showLog(result.mResult);
                                  } else {
                                    command
                                        .execCommand(
                                            (Constants.ADB_WIRELESS_CONNECT +
                                                    " " +
                                                    wireLessController.text)
                                                .split(" "))
                                        .then((value) {
                                      result = command.dealWithData(
                                          Constants.ADB_WIRELESS_CONNECT,
                                          value);
                                      if (result.mError) {
                                        _showLog(result.mResult);
                                        return;
                                      }
                                      currentAllDevice.insert(
                                          0, result.mResult);
                                      updateConnectDevice(currentAllDevice);
                                    }).catchError((e) {
                                      _showLog(e.toString());
                                    });
                                  }
                                }).catchError((e) {
                                  _showLog(e.toString());
                                });
                              } else {
                                if (Constants.currentDevice.isNotEmpty) {
                                  try {
                                    ProcessResult process =
                                        await command.execCommandSync(
                                            Constants.ADB_IP.split(" "));
                                    result = command.dealWithData(
                                        Constants.ADB_IP, process);
                                    if (result.mError) {
                                      _showLog(
                                          result.mResult + "获取ip失败，尝试手动输入连接");
                                    } else {
                                      deviceIp = result.mResult + ":5555";
                                      command
                                          .execCommand(Constants
                                              .ADB_FORWARD_PORT
                                              .split(" "))
                                          .then((value) {
                                        result = command.dealWithData(
                                            Constants.ADB_FORWARD_PORT, value);
                                        if (result.mError) {
                                          _showLog(result.mResult);
                                        } else {
                                          command
                                              .execCommand((Constants
                                                          .ADB_WIRELESS_CONNECT +
                                                      " " +
                                                      deviceIp)
                                                  .split(" "))
                                              .then((value) {
                                            result = command.dealWithData(
                                                Constants.ADB_WIRELESS_CONNECT,
                                                value);
                                            if (result.mError) {
                                              _showLog(result.mResult);
                                              return;
                                            }
                                            currentAllDevice.insert(
                                                0, result.mResult);
                                            updateConnectDevice(
                                                currentAllDevice);
                                          }).catchError((e) {
                                            _showLog(e.toString());
                                          });
                                        }
                                      }).catchError((e) {
                                        _showLog(e.toString());
                                      });
                                    }
                                  } catch (e) {
                                    _showLog(e.toString());
                                  }
                                } else {
                                  _showLog("请先获取真机设备");
                                }
                              }
                            } else {
                              if (_checkWireless == true) {
                                command
                                    .execCommand(
                                        (Constants.ADB_WIRELESS_CONNECT +
                                                " " +
                                                wireLessController.text)
                                            .split(" "))
                                    .then((value) {
                                  result = command.dealWithData(
                                      Constants.ADB_WIRELESS_CONNECT, value);
                                  if (result.mError) {
                                    _showLog(result.mResult);
                                    return;
                                  }
                                  currentAllDevice.insert(0, result.mResult);
                                  updateConnectDevice(currentAllDevice);
                                }).catchError((e) {
                                  _showLog(e.toString());
                                });
                              } else {
                                command
                                    .execCommand(
                                        (Constants.ADB_WIRELESS_CONNECT +
                                                " " +
                                                deviceIp)
                                            .split(" "))
                                    .then((value) {
                                  result = command.dealWithData(
                                      Constants.ADB_WIRELESS_CONNECT, value);
                                  if (result.mError) {
                                    _showLog(result.mResult);
                                    return;
                                  }
                                  currentAllDevice.insert(0, result.mResult);
                                  updateConnectDevice(currentAllDevice);
                                }).catchError((e) {
                                  _showLog(e.toString());
                                });
                              }
                            }
                          },
                          child: new Text("无线连接"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            if (Constants.currentDevice.isEmpty) {
                              _showLog("请先获取设备");
                            }
                            command
                                .execCommand(
                                    (Constants.ADB_WIRELESS_DISCONNECT +
                                            " " +
                                            Constants.currentDevice)
                                        .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_WIRELESS_DISCONNECT, value);
                              currentAllDevice.remove(result.mResult);
                              updateConnectDevice(currentAllDevice);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("断开"))),
                  Expanded(
                      child: DropdownButton<String?>(
                    value: currentWirelessDevice,
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) currentWirelessDevice = newValue;
                      });
                    },
                    items: wireLessDeviceDdmi,
                  )),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkWireless,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              if (isCheck != null && isCheck) {
                                FocusScope.of(context)
                                    .requestFocus(_wirelessFocus);
                              } else {
                                _wirelessFocus.unfocus();
                              }
                              setState(() {
                                _checkWireless = isCheck;
                              });
                            }),
                        new Text("自定义")
                      ])),
                  Expanded(
                      child: new TextField(
                    controller: wireLessController,
                    autofocus: false,
                    focusNode: _wirelessFocus,
                    decoration: InputDecoration(
                      labelText: "输入格式ip:port",
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide()),
                    ),
                  ))
                ],
              ),
              new Row(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  new Text("推送和拉取："),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                    onPressed: () async {
                      String? filePath = await _selectFile(context);
                      if (filePath == null) {
                        _showLog("未选择文件");
                      } else {
                        String pushPath = _checkPush == true
                            ? pushController.text
                            : "/data/local/tmp";
                        command.execCommand([
                          Constants.ADB_PUSH_FILE,
                          filePath,
                          pushPath
                        ]).then((value) {
                          result = command.dealWithData(
                              Constants.ADB_PUSH_FILE, value);
                          _showLog(result.mResult);
                        }).catchError((e) {
                          _showLog(e.toString());
                        });
                      }
                    },
                    child: new Text("push")),
              ]),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkPush,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              if (isCheck != null && isCheck) {
                                FocusScope.of(context).requestFocus(_pushFocus);
                              } else {
                                _pushFocus.unfocus();
                              }
                              setState(() {
                                _checkPush = isCheck;
                              });
                            }),
                        new Text("自定义路径")
                      ])),
                  Expanded(
                      child: new TextField(
                    controller: pushController,
                    autofocus: false,
                    focusNode: _pushFocus,
                    decoration: InputDecoration(
                      labelText: "默认路径/data/local/tmp",
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide()),
                    ),
                  ))
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                    child: TextButton(
                        onPressed: () {
                          if (isPullCrash) {
                            //正在拉取crash
                            if (currentPullFile.isNotEmpty) {
                              command
                                  .execCommand(
                                      Constants.ADB_PULL_CRASH_FILE.split(" ")
                                        ..addAll([
                                          currentPullFile,
                                          "--print",
                                          ">>",
                                          "crash.txt"
                                        ]),
                                      workingDirectory: Constants.desktopPath,
                                      runInShell: true)
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_CRASH_FILE, value);
                                if (result.mError) {
                                  _showLog(result.mResult);
                                } else {
                                  _showLog("拉取成功");
                                }
                              }).catchError((e) {
                                _showLog(e.toString());
                              });
                            } else {
                              _showLog("请先点击点击收集crash");
                            }
                          } else {
                            if (currentPullPath.isEmpty) {
                              _showLog("请先输入路径");
                              return;
                            }
                            if (currentPullFile.isEmpty) {
                              _showLog("请先点击搜索该路径下的文件");
                              return;
                            } else {
                              command.execCommand(
                                [
                                  Constants.ADB_PULL_FILE,
                                  currentPullPath + "/" + currentPullFile
                                ],
                                workingDirectory: Constants.desktopPath,
                              ).then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_CRASH_FILE, value);
                                if (result.mError) {
                                  _showLog(result.mResult);
                                } else {
                                  _showLog("拉取成功");
                                }
                              }).catchError((e) {
                                _showLog(e.toString());
                              });
                            }
                          }
                        },
                        child: new Text("拉取文件"))),
                Expanded(
                    child: TextButton(
                        onPressed: () {
                          command
                              .execCommand(Constants.ADB_PULL_CRASH.split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_PULL_CRASH, value);
                            if (result.mError) {
                              _showLog(result.mResult);
                            } else {
                              isPullCrash = true;
                              updatePull(result.mResult);
                            }
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("收集crash"))),
                Expanded(
                    child: TextButton(
                        onPressed: () {
                          command.execCommand([Constants.ADB_PULL_ANR],
                              workingDirectory:
                                  Constants.desktopPath).then((value) {
                            result = command.dealWithData(
                                Constants.ADB_PULL_ANR, value);
                            _showLog(result.mResult);
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("拉取anr"))),
              ]),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: new TextButton(
                          //todo
                          onPressed: () {
                            isPullCrash = false;
                            command
                                .execCommand(Constants.ADB_SEARCH_ALL_FILE_PATH
                                    .split(" ")
                                      ..addAll([pullController.text]))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_SEARCH_ALL_FILE_PATH, value);
                              if (result.mError) {
                                _showLog(result.mResult);
                              } else {
                                isPullCrash = false;
                                updatePull(result.mResult);
                                currentPullPath = pullController.text;
                              }
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("搜索"))),
                  Expanded(
                      child: new TextField(
                    controller: pullController,
                    autofocus: false,
                    focusNode: _pullFocus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                      //labelText: "文件路径",
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide()),
                    ),
                  )),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Wrap(children: [
                    DropdownButton<String?>(
                      value: currentPullFile,
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            currentPullFile = newValue;
                            // if (!isPullCrash) {
                            //   //pullController.text=
                            // }
                          }
                        });
                      },
                      items: pullDdmi,
                    )
                  ]),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ]));
  }
}

final TextEditingController adbController = new TextEditingController();
final TextEditingController wireLessController = new TextEditingController();
final TextEditingController pushController = new TextEditingController();
final TextEditingController pullController = new TextEditingController();
bool isPullCrash = false;

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
                    _settings['adb'] = adbController.text;
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
                                  controller: adbController,
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
          ),
        );
      });
}

/// 展示选择文件的弹窗
Future<String?> _selectFile(BuildContext context,
    {List<String>? extensions}) async {
  final typeGroup = XTypeGroup(
    //label: 'images',
    extensions: extensions,
  );
  final files = await FileSelectorPlatform.instance
      .openFiles(acceptedTypeGroups: [typeGroup]);
  if (files.isNotEmpty) {
    return files[0].path;
  }
  return null;
}

void _showLog(String msg) {
  if (msg.isEmpty) {
    return;
  }
  if (_showLogText.isEmpty) {
    _showLogText = ">>>>>>>" + _showLogText + msg.trim();
  } else {
    _showLogText = _showLogText + "\n" + ">>>>>>>" + msg.trim();
  }
  _logTextController.text = _showLogText;
}

_getWidthHeight(BuildContext context) {
  final size = MediaQuery.of(context).size;
  _width = size.width;
  _height = size.height;
}

_initAllWireLessDevice() {
  List<String> deviceName = [
    "真机",
    "逍遥模拟器",
    "网易MuMu模拟器",
    "蓝叠模拟器",
    "天天模拟器",
    "51模拟器",
    "雷电模拟器",
    "夜神模拟器",
    "海马玩模拟器",
    "iTools模拟器"
  ];
  deviceName.forEach((element) {
    wireLessDeviceDdmi.add(new DropdownMenuItem(
        child: new Text(
          element,
          style: _dropDownTextStyle(),
        ),
        value: element));
  });
  currentWirelessDevice = deviceName[0];
  return wireLessDeviceDdmi;
}

String _getDeviceIp(String device) {
  List<String> deviceName = [
    "真机",
    "逍遥模拟器",
    "网易MuMu模拟器",
    "蓝叠模拟器",
    "天天模拟器",
    "51模拟器",
    "雷电模拟器",
    "夜神模拟器",
    "海马玩模拟器",
    "iTools模拟器"
  ];
  int index = deviceName.indexOf(device);
  switch (index) {
    case 1:
      return "127.0.0.1:21503";
    case 2:
      return "127.0.0.1:7555";
    case 3:
      return "127.0.0.1:5555";
    case 4:
      return "127.0.0.1:6555";
    case 5:
      return "127.0.0.1:5555";
    case 6:
      return "127.0.0.1:5555";
    case 7:
      return "127.0.0.1:62001";
    case 8:
      return "127.0.0.1:26944";
    case 9:
      return "127.0.0.1:62001";
    default:
      return "0"; //真机
  }
}

TextStyle _dropDownTextStyle() {
  return TextStyle(fontSize: 12, color: Colors.blue);
}
