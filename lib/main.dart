import 'dart:convert';
import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_command_tools/command/Command.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/utils/FileUtils.dart';
import 'package:flutter_mobile_command_tools/utils/InitUtils.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';
import 'package:flutter_mobile_command_tools/utils/TimeUtils.dart';

var _width = 0.0;
var _height = 0.0;

///目前保存adb路径(自定义的)，是否root开启，是否启用内部路径
Map<String, dynamic> _settings = {};

var _apksigner = {};
String _showLogText = ""; //展示日志的信息
late CommandResult result; //命令的结果
List<DropdownMenuItem<String>> connectDeviceDdmi = []; //获取设备下拉框的列表
List<DropdownMenuItem<String>> allPackageNameDdmi = []; //获取设备下拉框的列表

List<String> currentAllDevice = []; //当前所有连接的设备
List<String> currentAllPackageName = []; //当前所有连接的包名

List<DropdownMenuItem<String>> wireLessDeviceDdmi = []; //无线连接下拉框的列表
List<DropdownMenuItem<String>> simOpDdmi = []; //下拉框的列表
List<DropdownMenuItem<String>> phoneInfoDdmi = []; //手机信息下拉框的列表
List<DropdownMenuItem<String>> broadcastReceiverDdmi = []; //手机信息下拉框的列表

List<DropdownMenuItem<String>> pullDdmi = []; //下拉框的列表
final AndroidCommand command = new AndroidCommand(); //命令信息

late String currentWirelessDevice; //当前需要连接的无线设备
late String currentPhoneInfo; //当前需要获取的手机信息
String currentSimOp = ""; //当前的模拟操作
String currentPullPath = ""; //当前pull文件的路径
String currentPullFile = ""; //当前pull文件的路径

void main() async {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await InitUtils.init(_settings); //等待配置初始化完成
    _initAllWireLessDevice();
    _initAllPhoneInfo();
    Future.delayed(Duration(milliseconds: 50), () {
      runApp(new MaterialApp(
        home: MyApp(),
      ));
    });
  } else {
    print("不支持当前平台");
  }
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
                  adbController.text = Constants.outerAdbPath;
                  //执行函数
                  showSettingDialog(context);
                },
                icon: new Icon(Icons.settings)),
            new IconButton(
                onPressed: () async {
                  _showLogText = "";
                  _logTextController.clear();
                },
                icon: new Icon(Icons.delete))
          ],
        ),
        body: new Container(
          child: new Row(
            children: [
              new Container(
                width: _width * 0.65,
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
                width: _width * 0.35,
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
FocusNode leftPanelFocus = FocusNode();

class LeftPanelState extends State<LeftPanel> {
  @override
  Widget build(BuildContext context) {
    return new TextField(
      controller: _logTextController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      //不限制行数
      enabled: true,
      autofocus: false,
      focusNode: leftPanelFocus,
      enableInteractiveSelection: true,
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
          Center(child: Text('敬请期待')),
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
  FocusNode _wirelessFocus = FocusNode(); //得到焦点
  FocusNode _pushFocus = FocusNode(); //得到焦点
  FocusNode _pullFocus = FocusNode(); //得到焦点
  bool? _checkWireless = false; //无线连接的复选框
  bool? _checkPush = false; //推送的复选框
  bool? _checkRepeat = false; //是否重复执行
  bool? _checkAllDevice = false;

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

  void updatePackageName(List<String> resultList) {
    setState(() {
      allPackageNameDdmi.clear();
      if (resultList.length > 0) {
        Constants.currentPackageName = resultList[0];
        resultList.toSet().forEach((element) {
          allPackageNameDdmi.add(new DropdownMenuItem(
            child: new Text(
              element,
              style: _dropDownTextStyle(fontTextSize: 18),
            ),
            value: element,
          ));
        });
      } else {
        Constants.currentPackageName = "";
      }
    });
  }

  void updateSimOpName(List<String> resultList) {
    setState(() {
      simOpDdmi.clear();
      if (resultList.length > 0) {
        Constants.currentSimOpName = resultList[0];
        resultList.toSet().forEach((element) {
          simOpDdmi.add(new DropdownMenuItem(
            child: new Text(
              element,
              style: _dropDownTextStyle(fontTextSize: 18),
            ),
            value: element,
          ));
        });
      } else {
        Constants.currentSimOpName = "";
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
              new Row(
                children: [
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: Constants.isRoot,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              setState(() {});
                              if (isCheck!) {
                                _settings['isRoot'] = true;
                              } else {
                                _settings['isRoot'] = false;
                              }
                              FileUtils.writeSetting(_settings);
                              Constants.isRoot = isCheck;
                            }),
                        new Text("开启Root")
                      ])),
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: Constants.isInnerAdb,
                            activeColor: Colors.red,
                            onChanged: (isCheck) async {
                              if (isCheck!) {
                                /// 存储是否使用内部adb
                                /// 存储内部adb路径（只有一次）
                                /// 赋值当前adb路径
                                _settings[Constants.isInnerAdbKey] = true;
                                if (_settings[Constants.innerKey] == null) {
                                  _settings[Constants.innerKey] =
                                      await FileUtils.getInnerAdbPath();
                                }
                                Constants.adbPath =
                                    _settings[Constants.innerKey];
                              } else {
                                /// 赋值当前adb路径
                                /// 存储当前外部adb路径、
                                /// 存储是否使用内部adb
                                Constants.adbPath = Constants.outerAdbPath;
                                _settings[Constants.isInnerAdbKey] = false;
                                _settings[Constants.outerKey] =
                                    Constants.outerAdbPath;
                              }
                              await FileUtils.writeSetting(_settings);
                              _getAdbVersion();
                              setState(() {});
                              Constants.isInnerAdb = isCheck;
                            }),
                        new Text("内置ADB")
                      ])),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              new Row(children: [
                new Text(
                  "基本操作：",
                  style: _tipTextStyle(),
                )
              ]),
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
                    isExpanded: true,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            int index = phoneInfo.indexOf(currentPhoneInfo);
                            command
                                .execCommand(
                                    Constants.getPhoneInfo(index).split(" "),
                                    runInShell: true)
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.getPhoneInfo(index), value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("获取设备信息"))),
                  Expanded(
                      child: DropdownButton<String>(
                    isExpanded: true,
                    value: currentPhoneInfo,
                    onChanged: (String? newValue) {
                      setState(() {
                        currentPhoneInfo = newValue!;
                      });
                    },
                    items: phoneInfoDdmi,
                  )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              new Row(children: [new Text("无线连接：", style: _tipTextStyle())]),
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
                                  } else {
                                    currentAllDevice.insert(0, result.mResult);
                                    updateConnectDevice(currentAllDevice);
                                  }
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
                              if (result.mError) {
                                _showLog(result.mResult);
                                return;
                              }
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
              SizedBox(
                height: 10,
              ),
              new Row(children: [
                new Text(
                  "应用管理：",
                  style: _tipTextStyle(),
                )
              ]),
              new Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: DropdownButton<String>(
                    isExpanded: true,
                    value: Constants.currentPackageName,
                    onChanged: (String? newValue) {
                      setState(() {
                        Constants.currentPackageName =
                            newValue == null ? "" : newValue;
                      });
                    },
                    items: allPackageNameDdmi,
                  )),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              new Row(
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
                                updatePackageName([]);
                                _showLog(result.mResult);
                              } else {
                                updatePackageName([result.mResult]);
                                _showLog("当前应用包名获取成功");
                              }
                            }).catchError((e) {
                              updatePackageName([]);
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("当前包名"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            command
                                .execCommand(
                                    Constants.ADB_GET_THIRD_PACKAGE.split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_GET_THIRD_PACKAGE, value);
                              if (result.mError) {
                                updatePackageName([]);
                                _showLog(result.mResult);
                              } else {
                                updatePackageName(result.mResult);
                                _showLog("第三方应用所有包名获取成功");
                              }
                            }).catchError((e) {
                              updatePackageName([]);
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("第三方包名"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            command
                                .execCommand(
                                    Constants.ADB_GET_SYSTEM_PACKAGE.split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_GET_SYSTEM_PACKAGE, value);
                              if (result.mError) {
                                updatePackageName([]);
                                _showLog(result.mResult);
                              } else {
                                updatePackageName(result.mResult);
                                _showLog("系统应用所有包名获取成功");
                              }
                            }).catchError((e) {
                              updatePackageName([]);
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("系统包名"))),
                ],
              ),
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
                            if (Constants.currentPackageName.isEmpty) {
                              _showLog("请先获取包名");
                              return;
                            }
                            command
                                .execCommand(Constants.ADB_UNINSTALL_APK
                                    .replaceAll(
                                        "package", Constants.currentPackageName)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_UNINSTALL_APK, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("卸载apk"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            if (Constants.currentPackageName.isEmpty) {
                              _showLog("请先获取包名");
                              return;
                            }
                            command
                                .execCommand(Constants.ADB_APK_PATH
                                    .replaceAll(
                                        "package", Constants.currentPackageName)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_APK_PATH, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("app安装路径"))),
                ],
              ),
              new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          if (Constants.currentPackageName.isEmpty) {
                            _showLog("请先获取包名");
                            return;
                          }
                          command
                              .execCommand((Constants.ADB_GET_PACKAGE_INFO +
                                      Constants.currentPackageName)
                                  .split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_GET_PACKAGE_INFO, value);
                            _showLog(Constants.currentPackageName +
                                "包信息：\n" +
                                result.mResult);
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("app包信息"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          command
                              .execCommand(
                                  Constants.ADB_CURRENT_ACTIVITY.split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_CURRENT_ACTIVITY, value);
                            _showLog(result.mResult);
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("前台Activity"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          if (Constants.currentPackageName.isEmpty) {
                            _showLog("请先获取包名");
                            return;
                          }
                          command
                              .execCommand(Constants.ADB_CLEAR_DATA.split(" ")
                                ..add(Constants.currentPackageName))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_CLEAR_DATA, value);
                            _showLog(result.mResult);
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("清除数据")))
              ]),
              SizedBox(
                height: 10,
              ),
              new Row(children: [
                new Text(
                  "应用交互：",
                  style: _tipTextStyle(),
                )
              ]),
              new Row(
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String resultActivity = await showMutualAppDialog(
                                context, "开启Activity");
                            if (resultActivity.isEmpty) {
                              if (Constants.currentPackageName.isEmpty) {
                                _showLog("当前模式请先获取包名");
                                return;
                              }
                              if (Constants.currentPackageName.isNotEmpty) {
                                command
                                    .execCommand(Constants.ADB_START_ACTIVITY_NO
                                        .replaceAll("package",
                                            Constants.currentPackageName)
                                        .split(" "))
                                    .then((value) {
                                  result = command.dealWithData(
                                      Constants.ADB_START_ACTIVITY_NO, value);
                                  if (!result.mError) {
                                    _showLog("开启Activity成功：" + result.mResult);
                                  } else {
                                    _showLog("开启Activity失败：" + result.mResult);
                                  }
                                }).catchError((error) {
                                  _showLog(error.toString());
                                });
                              }
                            } else {
                              command
                                  .execCommand((Constants.ADB_START_ACTIVITY +
                                          resultActivity)
                                      .split(" "))
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_START_ACTIVITY, value);
                                if (!result.mError) {
                                  _showLog("开启Activity成功：" + result.mResult);
                                } else {
                                  _showLog("开启Activity失败：" + result.mResult);
                                }
                              }).catchError((error) {
                                _showLog(error.toString());
                              });
                            }
                          },
                          child: new Text("启动Activity"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String resultReceiver = await showMutualAppDialog(
                                context, "发送BroadcastReceiver");
                            if (resultReceiver.isEmpty) {
                              _showLog("发送空广播");
                              return;
                            }
                            command
                                .execCommand(
                                    (Constants.ADB_START_BROADCAST_RECEIVER +
                                            resultReceiver)
                                        .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_START_BROADCAST_RECEIVER,
                                  value);
                              if (!result.mError) {
                                _showLog("开启广播成功：" + result.mResult);
                              } else {
                                _showLog("开启广播失败：" + result.mResult);
                              }
                            }).catchError((error) {
                              _showLog(error.toString());
                            });
                          },
                          child: new Text("发送BroadcastReceiver"))),
                ],
              ),
              new Row(
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String resultService =
                                await showMutualAppDialog(context, "发送Service");
                            if (resultService.isEmpty) {
                              _showLog("发送空Service");
                              return;
                            }
                            command
                                .execCommand((Constants.ADB_START_SERVICE +
                                        resultService)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_START_SERVICE, value);
                              if (!result.mError) {
                                _showLog("开启Service成功：" + result.mResult);
                              } else {
                                _showLog("开启Service失败：" + result.mResult);
                              }
                            }).catchError((error) {
                              _showLog(error.toString());
                            });
                          },
                          child: new Text("发送Service"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String resultService =
                                await showMutualAppDialog(context, "停止Service");
                            if (resultService.isEmpty) {
                              _showLog("停止空Service");
                              return;
                            }
                            command
                                .execCommand(
                                    (Constants.ADB_STOP_SERVICE + resultService)
                                        .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_STOP_SERVICE, value);
                              if (!result.mError) {
                                _showLog("停止Service成功：" + result.mResult);
                              } else {
                                _showLog("开停止Service失败：" + result.mResult);
                              }
                            }).catchError((error) {
                              _showLog(error.toString());
                            });
                          },
                          child: new Text("停止Service"))),
                ],
              ),
              new Row(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  new Text("文件管理：", style: _tipTextStyle()),
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
                    child: new Text("推送文件")),
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
                      hintText: "文件路径",
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
                  Expanded(
                      child: DropdownButton<String?>(
                    isExpanded: true,
                    value: currentPullFile,
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) {
                          currentPullFile = newValue;
                        }
                      });
                    },
                    items: pullDdmi,
                  )),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
              new Row(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  new Text("模拟操作：", style: _tipTextStyle()),
                ],
              ),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Center(
                          child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                        DropdownButton<String?>(
                          value: Constants.currentSimOpName,
                          onChanged: (String? newValue) {
                            setState(() {
                              Constants.currentSimOpName =
                                  newValue == null ? "" : newValue;
                            });
                          },
                          items: simOpDdmi,
                        )
                      ]))),
                  Expanded(
                      child: TextButton(
                    onPressed: () async {
                      String? path = await _selectFile(context);
                      if (path == null) {
                        _showLog("未选择指令文件");
                      } else {
                        List<String>? commandsName =
                            await _analyseSimFile(path);
                        if (commandsName != null) {
                          updateSimOpName(commandsName);
                        }
                      }
                    },
                    child: new Text("添加指令文件"),
                  )),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
              new Row(
                children: [
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkRepeat,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              setState(() {
                                _checkRepeat = isCheck;
                              });
                            }),
                        new Text("是否循环")
                      ])),
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkAllDevice,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              setState(() {
                                _checkAllDevice = isCheck;
                              });
                            }),
                        new Text("所有设备")
                      ])),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: TextButton(
                    onPressed: () async {
                      if (Constants.currentSimOpName.isEmpty) {
                        _showLog("请先添加模拟指令文件");
                        return;
                      }
                      if (currentAllDevice.length == 0) {
                        _showLog("当前无设备连接,请先获取设备");
                        return;
                      }
                      if (Constants.currentSimType == 0) {
                        String? times = await showSimDelayTimes(context);
                        if (times.isEmpty) {
                          simOpTimeController.text = "1000"; //如果值为空，延迟默认为1s
                        }
                      } else {
                        simOpTimeController.text = "100";
                      }
                      _startSimOperation(_checkAllDevice, _checkRepeat);
                    },
                    child: Text("执行命令"),
                  )),
                  Expanded(
                      child: TextButton(
                    onPressed: () {
                      _stopSimOperation();
                    },
                    child: Text("停止命令"),
                  )),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
              new Row(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  new Text("刷机相关：", style: _tipTextStyle()),
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
                          child: new Text("重启手机"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            command
                                .execCommand(
                                    Constants.ADB_REBOOT_BOOTLOADER.split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_REBOOT_BOOTLOADER, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("重启到fastboot"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            command
                                .execCommand(
                                    Constants.ADB_REBOOT_RECOVERY.split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_REBOOT_RECOVERY, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("重启到recovery"))),
                ],
              ),
              new Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String fastbootPath =
                                await FileUtils.getInnerFastBootPath();
                            command
                                .execCommand(
                                    Constants.FASTBOOT_UNLOCK.split(" "),
                                    executable: fastbootPath)
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.FASTBOOT_UNLOCK, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("解锁"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String fastbootPath =
                                await FileUtils.getInnerFastBootPath();
                            command
                                .execCommand(Constants.FASTBOOT_LOCK.split(" "),
                                    executable: fastbootPath)
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.FASTBOOT_LOCK, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("锁定"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String fastbootPath =
                                await FileUtils.getInnerFastBootPath();
                            command
                                .execCommand(
                                    Constants.FASTBOOT_LOCK_STATE.split(" "),
                                    executable: fastbootPath)
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.FASTBOOT_LOCK_STATE, value);
                              _showLog(result.mResult);
                            }).catchError((e) {
                              _showLog(e.toString());
                            });
                          },
                          child: new Text("获取锁的状态"))),
                ],
              ),
              new Row(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  new Text("实用操作：", style: _tipTextStyle()),
                ],
              ),
              new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          String pngName = TimeUtils.getCurrentTimeFormat();
                          command
                              .execCommand(Constants.ADB_SCREEN_SHOT
                                  .replaceAll("shoot", pngName)
                                  .split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_SCREEN_SHOT, value);
                            if (!result.mError) {
                              _showLog("截屏成功");
                              command
                                  .execCommand(
                                      Constants.ADB_PULL_SCREEN_SHOT
                                          .replaceAll("shoot", pngName)
                                          .split(" "),
                                      workingDirectory: Constants.desktopPath)
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_SCREEN_SHOT, value);
                                _showLog(result.mResult);
                              });
                            } else {
                              _showLog(result.mResult);
                            }
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("截屏"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () async {
                          String times = await showScreenRecordDialog(context);
                          String recordName = TimeUtils.getCurrentTimeFormat();
                          command
                              .execCommand(Constants.ADB_SCREEN_RECORD
                                  .replaceAll("times", times)
                                  .replaceAll("record_screen", recordName)
                                  .split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_SCREEN_RECORD, value);
                            if (!result.mError) {
                              _showLog("录屏结束");
                              command
                                  .execCommand(
                                      Constants.ADB_PULL_SCREEN_RECORD
                                          .replaceAll(
                                              "record_screen", recordName)
                                          .split(" "),
                                      workingDirectory: Constants.desktopPath)
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_SCREEN_RECORD, value);
                                _showLog(result.mResult);
                              });
                            } else {
                              _showLog(result.mResult);
                            }
                          }).catchError((e) {
                            _showLog(e.toString());
                          });
                        },
                        child: new Text("录屏")))
              ]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () async {
                            String? apkPath =
                                await _selectFile(context, extensions: ["apk"]);
                            if (!await FileUtils.isExistFile(
                                Constants.signerPath.path)) {
                              _showLog("apksigner签名文件不存在");
                              return;
                            } else {
                              if (_apksigner.length == 0) {
                                String value = await FileUtils.readFile(
                                    Constants.signerPath);
                                if (value.isNotEmpty) {
                                  Map<String, dynamic> map = jsonDecode(value);
                                  _apksigner = map;
                                }
                              }
                              String commandStr = Constants.APK_SIGNER
                                  .replaceAll(
                                      "apksign", Constants.signerJarPath.path)
                                  .replaceAll(
                                      "jks_path", Constants.jksPath.path)
                                  .replaceAll("myalias", _apksigner['alias'])
                                  .replaceAll("mypass", _apksigner["ks_pass"])
                                  .replaceAll(
                                      "mykeypass", _apksigner["key_pass"])
                                  .replaceAll("outapk", "signer.apk")
                                  .replaceAll("inputapk",
                                      apkPath == null ? "" : apkPath);
                              PlatformUtils.runCommand(commandStr,
                                      runInShell: true,
                                      workDirectory: Constants.desktopPath)
                                  .then((value) {
                                if (value.stderr.toString().isEmpty) {
                                  _showLog("签名成功");
                                } else {
                                  _showLog(value.stderr.toString());
                                }
                              }).catchError((e) {
                                _showLog(e.toString());
                              });
                            }
                          },
                          child: Text("v2签名"))),
                  new Expanded(
                      child: TextButton(
                    onPressed: () async {
                      String? apkPath =
                          await _selectFile(context, extensions: ["apk"]);
                      if (!await FileUtils.isExistFile(
                          Constants.signerPath.path)) {
                        _showLog("apksigner签名文件不存在");
                        return;
                      } else {
                        if (_apksigner.length == 0) {
                          String value =
                              await FileUtils.readFile(Constants.signerPath);
                          if (value.isNotEmpty) {
                            Map<String, dynamic> map = jsonDecode(value);
                            _apksigner = map;
                          }
                        }
                        String commandStr = Constants.VERIFY_APK_SIGNER
                            .replaceAll("apksign", Constants.signerJarPath.path)
                            .replaceAll(
                                "inputapk", apkPath == null ? "" : apkPath);
                        print(commandStr);
                        PlatformUtils.runCommand(commandStr,
                                runInShell: true,
                                workDirectory: Constants.desktopPath)
                            .then((value) {
                          if (value.stderr.toString().isEmpty) {
                            _showLog(value.stdout);
                          } else {
                            _showLog(value.stderr);
                          }
                        }).catchError((e) {
                          _showLog(e.toString());
                        });
                      }
                    },
                    child: new Text("校验签名"),
                  ))
                ],
              )
            ]));
  }
}

final TextEditingController adbController = new TextEditingController();
final TextEditingController mutualAppController = new TextEditingController();
final TextEditingController apkSignerController = new TextEditingController();

final TextEditingController wireLessController = new TextEditingController();
final TextEditingController pushController = new TextEditingController();
final TextEditingController pullController = new TextEditingController();
final TextEditingController simOpTimeController = new TextEditingController();
final TextEditingController screenRecordController =
    new TextEditingController();

bool isPullCrash = false; //当前需要拉取普通文件还是crash文件

showSettingDialog(BuildContext context) {
  bool checkboxSelected = true;
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
                    _settings[Constants.outerKey] = adbController.text;
                    if (!Constants.isInnerAdb) {
                      Constants.adbPath = adbController.text;
                    }
                    Constants.outerAdbPath = adbController.text;
                    FileUtils.writeSetting(_settings);
                    Navigator.of(context).pop();
                    _getAdbVersion();
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new TextButton(
                                    onPressed: () async {
                                      String? path = await _selectFile(context);
                                      if (path == null) {
                                        _showLog("未选择adb文件");
                                      } else {
                                        adbController.text = path;
                                      }
                                    },
                                    child: new Text("adb")),
                                new Expanded(
                                    child: TextField(
                                  controller: adbController,
                                  decoration: InputDecoration(
                                    enabled: false,
                                    labelText: 'adb',
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

String currentBroadcastReceiver = "";
String currentActivity = "";
String currentService = "";

String showTips = "";

String getCurrentType(String sceneStr) {
  if (sceneStr.contains("Activity")) {
    showTips = "Activity不填默认会启动你获取的包名App";
    return currentActivity;
  } else if (sceneStr.contains("Service")) {
    showTips = "";
    return currentService;
  } else {
    showTips = "支持的系统广播(可复制)\n" + broadcastReceiver.join("\n");
    return currentBroadcastReceiver;
  }
}

setCurrentType(String sceneStr, String value) {
  if (sceneStr.contains("Activity")) {
    currentActivity = value;
  } else if (sceneStr.contains("Service")) {
    currentService = value;
  } else {
    currentBroadcastReceiver = value;
  }
}

///展示交互APP的弹窗
Future<String> showMutualAppDialog(
    BuildContext context, String sceneStr) async {
  mutualAppController.text = getCurrentType(sceneStr);
  var result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
                    setCurrentType(sceneStr, mutualAppController.text);
                    Navigator.of(context).pop(mutualAppController.text);
                  },
                )
              ],
              title: new Text(sceneStr, style: new TextStyle(fontSize: 20)),
              content: new Center(
                  child: new Container(
                      //color: Color.fromARGB(255, 250, 255, 0),
                      width: 0.3 * _width,
                      height: 0.35 * _height,
                      child: new SingleChildScrollView(
                        child: new Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new Expanded(
                                    child: TextField(
                                  controller: mutualAppController,
                                  decoration: InputDecoration(
                                    labelText: sceneStr,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: new SelectableText(
                                    showTips,
                                    maxLines: null,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ))),
            ),
          ),
        );
      });
  return result;
}

///展示获取模拟命令延迟的弹窗
Future<String> showSimDelayTimes(BuildContext context) async {
  var result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
                    Navigator.of(context).pop(simOpTimeController.text);
                  },
                )
              ],
              title: new Text("延迟", style: new TextStyle(fontSize: 20)),
              content: new Center(
                  child: new Container(
                      //color: Color.fromARGB(255, 250, 255, 0),
                      width: 0.3 * _width,
                      height: 0.35 * _height,
                      child: new SingleChildScrollView(
                        child: new Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new Expanded(
                                    child: TextField(
                                  controller: simOpTimeController,
                                  decoration: InputDecoration(
                                    labelText: "延迟时间,单位毫秒",
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
  return result;
}

Future<String> showScreenRecordDialog(BuildContext context) async {
  var times = await showDialog(
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
                    if (screenRecordController.text.isEmpty) {
                      _showLog("时间不能设置为空");
                      return;
                    }
                    Navigator.of(context).pop(screenRecordController.text);
                  },
                )
              ],
              title: new Text("录屏设置", style: new TextStyle(fontSize: 20)),
              content: new Center(
                  child: new Container(
                      //color: Color.fromARGB(255, 250, 255, 0),
                      width: 0.3 * _width,
                      height: 0.1 * _height,
                      child: new SingleChildScrollView(
                        child: new Column(
                          children: [
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new Expanded(
                                    child: TextField(
                                  controller: screenRecordController,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "录屏时间(s)",
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
  return times;
}

List<String> simCommand = [];
List<String> simCommandName = [];

Future<List<String>?> _analyseSimFile(String path) async {
  simCommandName.clear();
  simCommand.clear();
  String fileStr = await FileUtils.readFile(File(path));
  List<String> commands = fileStr.split(PlatformUtils.getLineBreak());
  if (commands[0] != "0" && commands[0] != "1") {
    _showLog("文本开始必须以0或者1");
    return null;
  }

  for (int i = 1; i < commands.length; i++) {
    if (commands[i].startsWith("swipe")) {
      //滑动指令
      //simOperation.name
      List<String> commandSwipe = commands[i].split(" ");
      if (commandSwipe.length >= 6) {
        simCommand.add(Constants.ADB_SIM_SWIPE +
            " " +
            commandSwipe[1] +
            " " +
            commandSwipe[2] +
            " " +
            commandSwipe[3] +
            " " +
            commandSwipe[4]);
        simCommandName.add(commandSwipe[5]);
      } else {
        _showLog("滑动格式不对");
      }
    } else if (commands[i].startsWith("tap")) {
      List<String> commandTap = commands[i].split(" ");
      if (commandTap.length >= 2) {
        simCommand.add(Constants.ADB_SIM_TAP);
        simCommandName.add(commandTap[1]);
      } else {
        _showLog("点击格式不对");
      }
    } else if (commands[i].startsWith("text")) {
      List<String> commandText = commands[i].split(" ");
      if (commandText.length >= 3) {
        simCommand.add(Constants.ADB_SIM_TAP + " " + commandText[2]);
        simCommandName.add(commandText[3]);
      } else {
        _showLog("输入文字格式不对");
      }
    } else {
      //输入的是键值
      List<String> commandKeyCode = commands[i].split(" ");
      if (commandKeyCode.length >= 2) {
        simCommand.add(Constants.ADB_SIM_KEY_EVENT + " " + commandKeyCode[0]);
        simCommandName.add(commandKeyCode[1].toLowerCase());
      } else {
        _showLog("键值格式不对");
      }
    }
  }
  if (commands[0] == "0") {
    Constants.currentSimType = 0;
    simCommandName.clear();
    simCommandName.add(path.split(PlatformUtils.getSeparator()).last);
    return simCommandName;
  } else if (commands[0] == "1") {
    Constants.currentSimType = 1;
    return simCommandName;
  }
  // List<String> returnList=[];
//  returnList.addAll(simCommandName);
  return simCommandName;
}

bool _opRepeat = false;

void _startSimOperation(bool? checkAllDevice, bool? checkRepeat) {
  // List<SimOperation> listOps = []..addAll(_simOpList);

  _opRepeat = checkRepeat == true;
  List<String> listDevices = [];
  if (checkAllDevice == true) {
    listDevices..addAll(currentAllDevice);
  } else {
    listDevices.add(Constants.currentDevice);
  }

  listDevices.forEach((element) {
    if (Constants.currentSimType == 1) {
      _runCommand(
          [simCommand[simCommandName.indexOf(Constants.currentSimOpName)]],
          element);
    } else {
      _runCommand(simCommand, element);
    }
  });
  //});
}

///todo 循环操作值得被优化
_runCommand(List<String> listOps, String device) {
  List<Future> futureList = [];
  listOps.forEach((element) {
    futureList.add(Future.delayed(
        Duration(milliseconds: int.parse(simOpTimeController.text)), () {
      List<String> arguments = ["-s", device]..addAll(element.split(" "));
      //_showLog("执行指令：arguments:$arguments");
      ProcessResult result = Process.runSync(Constants.adbPath, arguments);
      _showLog("执行结束：$arguments" + result.stdout + result.stderr);
    }));
  });

  Future.wait(futureList).then((value) {
    if (_opRepeat) {
      _runCommand(listOps, device);
    }
  });
}

void _stopSimOperation() {
  _opRepeat = false;
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
  leftPanelFocus.unfocus();
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
    "SubSystem",
    "逍遥模拟器",
    "MuMu模拟器",
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

List<String> phoneInfo = [];

_initAllPhoneInfo() {
  phoneInfo = [
    "蓝牙 MAC地址",
    "WIFI MAC地址",
    "IP 地址",
    "显示信息",
    "CPU信息",
    "电池信息",
    "内存信息",
    "版本信息",
  ];
  phoneInfo.forEach((element) {
    phoneInfoDdmi.add(new DropdownMenuItem(
        child: new Text(
          element,
          style: _dropDownTextStyle(),
        ),
        value: element));
  });
  currentPhoneInfo = phoneInfo[0];
  return phoneInfoDdmi;
}

List<String> broadcastReceiver = [
  "android.net.conn.CONNECTIVITY_CHANGE",
  //网络连接发生变化
  "android.intent.action.SCREEN_ON",
  //屏幕点亮
  "android.intent.action.SCREEN_OFF",
  //屏幕熄灭
  "android.intent.action.BATTERY_LOW",
  //电量低，会弹出电量低提示框
  "android.intent.action.BATTERY_OKAY",
  //电量恢复了
  "android.intent.action.BOOT_COMPLETED",
  //设备启动完毕
  "android.intent.action.DEVICE_STORAGE_LOW",
  //存储空间过低
  "android.intent.action.DEVICE_STORAGE_OK",
  //存储空间恢复
  "android.intent.action.PACKAGE_ADDED",
  //安装了新的应用
  "android.net.wifi.STATE_CHANGE",
  //WiFi 连接状态发生变化
  "android.net.wifi.WIFI_STATE_CHANGED",
  //WiFi 状态变为启用/关闭/正在启动/正在关闭/未知
  "android.intent.action.BATTERY_CHANGED",
  //电池电量发生变化
  "android.intent.action.INPUT_METHOD_CHANGED",
  //系统输入法发生变化
  "android.intent.action.ACTION_POWER_CONNECTED",
  //外部电源连接
  "android.intent.action.ACTION_POWER_DISCONNECTED",
  //外部电源断开连接
  "android.intent.action.DREAMING_STARTED",
  //系统开始休眠
  "android.intent.action.DREAMING_STOPPED",
  //系统停止休眠
  "android.intent.action.WALLPAPER_CHANGED",
  //壁纸发生变化
  "android.intent.action.HEADSET_PLUG",
  //插入耳机
  "android.intent.action.MEDIA_UNMOUNTED",
  //卸载外部介质
  "android.intent.action.MEDIA_MOUNTED",
  //挂载外部介质
  "android.os.action.POWER_SAVE_MODE_CHANGED",
];

String _getDeviceIp(String device) {
  List<String> deviceName = [
    "真机",
    "SubSystem",
    "逍遥模拟器",
    "MuMu模拟器",
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
      return "127.0.0.1:58526";
    case 2:
      return "127.0.0.1:21503";
    case 3:
      return "127.0.0.1:7555";
    case 4:
      return "127.0.0.1:5555";
    case 5:
      return "127.0.0.1:6555";
    case 6:
      return "127.0.0.1:5555";
    case 7:
      return "127.0.0.1:5555";
    case 8:
      return "127.0.0.1:62001";
    case 9:
      return "127.0.0.1:26944";
    case 10:
      return "127.0.0.1:62001";
    default:
      return "0"; //真机
  }
}

void _getAdbVersion() {
  command.execCommand([Constants.ADB_VERSION]).then((value) {
    result = command.dealWithData(Constants.ADB_VERSION, value);
    _showLog(result.mResult);
  }).catchError((error) {
    _showLog(error.toString());
  });
}

TextStyle _dropDownTextStyle({double fontTextSize = 12}) {
  return TextStyle(fontSize: fontTextSize, color: Colors.black);
}

TextStyle _tipTextStyle() {
  return TextStyle(
      fontSize: 18,
      color: Colors.red,
      //decoration: TextDecoration.underline,
      fontWeight: FontWeight.bold);
}
