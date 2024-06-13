import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobile_command_tools/command/Command.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/notifier/global/locale_change_notifier.dart';
import 'package:flutter_mobile_command_tools/route/route_helper.dart';
import 'package:flutter_mobile_command_tools/route/route_listener.dart';
import 'package:flutter_mobile_command_tools/utils/FileUtils.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';
import 'package:flutter_mobile_command_tools/utils/TimeUtils.dart';
import 'package:flutter_mobile_command_tools/utils/init_util.dart';
import 'package:flutter_mobile_command_tools/utils/sp_util.dart';
import 'package:flutter_mobile_command_tools/view/IOSRightPanel.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'notifier/global/theme_change_notifier.dart';

var _width = 0.0;
var _height = 0.0;

///目前保存adb路径(自定义的)，是否root开启，是否启用内部路径
Map<String, dynamic> _settings = {};

var _apksigner = {};
String showLogText = ""; //展示日志的信息
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

List<DropdownMenuItem<String>> mutualAppDdmi = []; //与App交互的列表

final AndroidCommand command = new AndroidCommand(); //命令信息

late String currentWirelessDevice; //当前需要连接的无线设备
late String currentPhoneInfo; //当前需要获取的手机信息
String currentSimOp = ""; //当前的模拟操作
String currentPullPath = ""; //当前pull文件的路径
String currentPullFile = ""; //当前pull文件的路径
String currentMutualApp = "";

String? simCommandPath;

void main() async {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await SpUtil.getInstance().initSp();
    await InitUtil.init(_settings); //等待配置初始化完成
    _initAllWireLessDevice();
    _initAllPhoneInfo();
    Future.delayed(Duration(milliseconds: 50), () {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeChangeNotifier()),
            ChangeNotifierProvider(create: (_) => LocaleChangeNotifier())
          ],
          child: _MyApp(),
        ),
      );
    });
  } else {
    print("不支持当前平台");
  }
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // onGenerateTitle: (context) {
      //   return S.of(context).setting;
      // },
      navigatorObservers: [RouteListener()],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorKey: Constants.navigatorKey,
      routes: RouteHelper.routes,
      onGenerateRoute: RouteHelper.onGenerateRoute,
      theme: Provider.of<ThemeChangeNotifier>(context).themeData,
      locale: Provider.of<LocaleChangeNotifier>(context).locale,
    );
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
                  javaController.text = Constants.javaPath;
                  //执行函数
                  showSettingDialog(context);
                },
                icon: new Icon(Icons.settings)),
            new IconButton(
                onPressed: () async {
                  showLogText = "";
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
                        child: new LeftPanel())
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

final LeftPanelState leftPanelState = new LeftPanelState();

/// 左边展示的面板
class LeftPanel extends StatefulWidget {
  @override
  LeftPanelState createState() {
    return leftPanelState;
  }
}

TextEditingController _logTextController = TextEditingController();
FocusNode leftPanelFocus = FocusNode();

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final ScrollController _scrollController = ScrollController();

class LeftPanelState extends State<LeftPanel> {
  late BuildContext context;

  @override
  void initState() {
    _logTextController.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new TextField(
      scrollController: _scrollController,
      controller: _logTextController,
      keyboardType: TextInputType.multiline,
      focusNode: leftPanelFocus,
      maxLines: null,
      //不限制行数
      autofocus: false,
      // 长按输入的文本, 设置是否显示剪切，复制，粘贴按钮, 默认是显示的
      enableInteractiveSelection: true,
      style: TextStyle(fontFamily: "simple", fontSize: 16),
      decoration: InputDecoration(
        labelText: "日志信息",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide()),
      ),
      onChanged: (value) {},
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
        children: [AndroidRightPanel(), IOSRightPanel()],
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
  bool? _lazyRandom = false;

  bool? _checkF = false;
  bool? _checkR = false;
  bool? _checkS = false;
  bool? _checkD = false;

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
              style: _dropDownTextStyle(fontTextSize: 14),
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
      } else {}
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
                            runCommand([Constants.ADB_CONNECT_DEVICES])
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_CONNECT_DEVICES, value);
                              if (result.mError) {
                                updateConnectDevice([]);
                                showLog(result.mResult);
                              } else {
                                currentAllDevice = result.mResult;
                                showLog("获取到的设备数量：" +
                                    currentAllDevice.length.toString());
                                currentAllDevice.forEach((element) {
                                  if (element.contains("offline")) {
                                    showLog(element + ",当前设备不在线,移出设备列表");
                                  } else if (element.contains("unauthorized")) {
                                    showLog("$element,请点击手机确定usb认证,移出列表");
                                  } else {
                                    showLog(element);
                                  }
                                });
                                currentAllDevice.removeWhere(
                                    (element) => element.contains("offline"));
                                currentAllDevice.removeWhere((element) =>
                                    element.contains("unauthorized"));
                                updateConnectDevice(currentAllDevice);
                              }
                            }).catchError((e) {
                              updateConnectDevice([]);
                              showLog(e.toString());
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
                            runCommand(Constants.getPhoneInfo(index).split(" "),
                                    runInShell: true)
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.getPhoneInfo(index), value);

                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
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
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            if (Constants.adbPath == "" ||
                                !await FileUtils.isExistFile(
                                    Constants.adbPath)) {
                              showLog("请先配置adb路径");
                              return;
                            }
                            String adbCommandPath =
                                await FileUtils.getMutualAppPath("adb");
                            String adbCommand = await showMutualAppDialog(
                                context, adbCommandPath, "自定义adb命令",
                                tips: "不需要加前缀adb");
                            if (adbCommand.isNotEmpty) {
                              showLog("执行命令：${Constants.adbPath} $adbCommand");
                              PlatformUtils.runCommand(adbCommand,
                                      workDirectory: Constants.desktopPath,
                                      isAdbCommand: true)
                                  .then((value) =>
                                      {showLog(value.stdout + value.stderr)})
                                  .onError((error, stackTrace) =>
                                      {showLog(error.toString())});
                            }
                          },
                          child: new Text("自定义adb命令"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String otherCommand = await showMutualAppDialog(
                                context,
                                await FileUtils.getMutualAppPath("other"),
                                "自定义其他命令",
                                tips: "命令必须添加了环境变量");
                            if (otherCommand.isNotEmpty) {
                              showLog("执行命令：$otherCommand");
                              PlatformUtils.startCommand(otherCommand,
                                      runInShell: true,
                                      workDirectory: Constants.desktopPath)
                                  .then((value) {
                                var stream = value.stdout;
                                stream.listen((event) {
                                  showLog(utf8.decode(event));
                                }, onError: (error) {
                                  showLog("解析数据出错：" + error);
                                });
                                utf8.decodeStream(value.stderr).then((value) {
                                  if (value.isNotEmpty) {
                                    showLog("执行出错：" + value);
                                  }
                                });
                                value.exitCode
                                    .then(
                                        (value) => {showLog("执行结束，退出码：$value")})
                                    .onError((error, stackTrace) =>
                                        {showLog("执行结束，出错：$error")});
                              });
                            }
                          },
                          child: new Text("自定义其他命令"))),
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
                                runCommand(
                                        Constants.ADB_FORWARD_PORT.split(" "))
                                    .then((value) {
                                  result = command.dealWithData(
                                      Constants.ADB_FORWARD_PORT, value);
                                  if (result.mError) {
                                    showLog(result.mResult);
                                  } else {
                                    runCommand((Constants.ADB_WIRELESS_CONNECT +
                                                " " +
                                                wireLessController.text)
                                            .split(" "))
                                        .then((value) {
                                      result = command.dealWithData(
                                          Constants.ADB_WIRELESS_CONNECT,
                                          value);
                                      if (result.mError) {
                                        showLog(result.mResult);
                                        return;
                                      }
                                      currentAllDevice.insert(
                                          0, result.mResult);
                                      updateConnectDevice(currentAllDevice);
                                    }).catchError((e) {
                                      showLog(e.toString());
                                    });
                                  }
                                }).catchError((e) {
                                  showLog(e.toString());
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
                                      showLog(
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
                                          showLog(result.mResult);
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
                                              showLog(result.mResult);
                                              return;
                                            }
                                            currentAllDevice.insert(
                                                0, result.mResult);
                                            updateConnectDevice(
                                                currentAllDevice);
                                          }).catchError((e) {
                                            showLog(e.toString());
                                          });
                                        }
                                      }).catchError((e) {
                                        showLog(e.toString());
                                      });
                                    }
                                  } catch (e) {
                                    showLog(e.toString());
                                  }
                                } else {
                                  showLog("请先获取真机设备");
                                }
                              }
                            } else {
                              if (_checkWireless == true) {
                                runCommand((Constants.ADB_WIRELESS_CONNECT +
                                            " " +
                                            wireLessController.text)
                                        .split(" "))
                                    .then((value) {
                                  result = command.dealWithData(
                                      Constants.ADB_WIRELESS_CONNECT, value);
                                  if (result.mError) {
                                    showLog(result.mResult);
                                    return;
                                  }
                                  currentAllDevice.insert(0, result.mResult);
                                  updateConnectDevice(currentAllDevice);
                                }).catchError((e) {
                                  showLog(e.toString());
                                });
                              } else {
                                runCommand((Constants.ADB_WIRELESS_CONNECT +
                                            " " +
                                            deviceIp)
                                        .split(" "))
                                    .then((value) {
                                  result = command.dealWithData(
                                      Constants.ADB_WIRELESS_CONNECT, value);
                                  if (result.mError) {
                                    showLog(result.mResult);
                                    return;
                                  } else {
                                    currentAllDevice.insert(0, result.mResult);
                                    updateConnectDevice(currentAllDevice);
                                  }
                                }).catchError((e) {
                                  showLog(e.toString());
                                });
                              }
                            }
                          },
                          child: new Text("无线连接"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            if (Constants.currentDevice.isEmpty) {
                              showLog("请先获取设备");
                            }
                            runCommand((Constants.ADB_WIRELESS_DISCONNECT +
                                        " " +
                                        Constants.currentDevice)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_WIRELESS_DISCONNECT, value);
                              if (result.mError) {
                                showLog(result.mResult);
                                return;
                              }
                              currentAllDevice.remove(result.mResult);
                              updateConnectDevice(currentAllDevice);
                            }).catchError((e) {
                              showLog(e.toString());
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
              new Row(children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          runCommand(Constants.ADB_GET_PACKAGE.split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_GET_PACKAGE, value);
                            if (result.mError) {
                              updatePackageName([]);
                              showLog(result.mResult);
                            } else {
                              updatePackageName([result.mResult]);
                              showLog("当前应用包名获取成功");
                            }
                          }).catchError((e) {
                            updatePackageName([]);
                            showLog(e.toString());
                          });
                        },
                        child: new Text("当前包名"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          runCommand(
                                  Constants.ADB_GET_FREEZE_PACKAGE.split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_GET_FREEZE_PACKAGE, value);
                            if (result.mError) {
                              updatePackageName([]);
                              showLog(result.mResult);
                            } else {
                              updatePackageName(result.mResult);
                              showLog("被冻结应用所有包名获取成功");
                            }
                          }).catchError((e) {
                            updatePackageName([]);
                            showLog(e.toString());
                          });
                        },
                        child: new Text("冻结包名"))),
              ]),
              new Row(
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            runCommand(
                                    Constants.ADB_GET_THIRD_PACKAGE.split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_GET_THIRD_PACKAGE, value);
                              if (result.mError) {
                                updatePackageName([]);
                                showLog(result.mResult);
                              } else {
                                updatePackageName(result.mResult);
                                showLog("第三方应用所有包名获取成功");
                              }
                            }).catchError((e) {
                              updatePackageName([]);
                              showLog(e.toString());
                            });
                          },
                          child: new Text("第三方包名"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            runCommand(
                                    Constants.ADB_GET_SYSTEM_PACKAGE.split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_GET_SYSTEM_PACKAGE, value);
                              if (result.mError) {
                                updatePackageName([]);
                                showLog(result.mResult);
                              } else {
                                updatePackageName(result.mResult);
                                showLog("系统应用所有包名获取成功");
                              }
                            }).catchError((e) {
                              updatePackageName([]);
                              showLog(e.toString());
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
                          onPressed: () {
                            if (Constants.currentPackageName.isEmpty) {
                              showLog("请先获取包名");
                              return;
                            }
                            runCommand(Constants.ADB_FREEZE_PACKAGE
                                    .replaceAll(
                                        "package", Constants.currentPackageName)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_FREEZE_PACKAGE, value);
                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
                            });
                          },
                          child: new Text("冷冻"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            if (Constants.currentPackageName.isEmpty) {
                              showLog("请先获取包名");
                              return;
                            }
                            runCommand(Constants.ADB_NOT_FREEZE_PACKAGE
                                    .replaceAll(
                                        "package", Constants.currentPackageName)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_NOT_FREEZE_PACKAGE, value);
                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
                            });
                          },
                          child: new Text("解冻"))),
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
                              showLog("未选择apk");
                              return;
                            }
                            runCommand([Constants.ADB_INSTALL_APK, apkPath])
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_INSTALL_APK, value);
                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
                            });
                          },
                          child: new Text("安装apk"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            if (Constants.currentPackageName.isEmpty) {
                              showLog("请先获取包名");
                              return;
                            }
                            runCommand(Constants.ADB_UNINSTALL_APK
                                    .replaceAll(
                                        "package", Constants.currentPackageName)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_UNINSTALL_APK, value);
                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
                            });
                          },
                          child: new Text("卸载apk"))),
                ],
              ),
              new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          if (Constants.currentPackageName.isEmpty) {
                            showLog("请先获取包名");
                            return;
                          }
                          runCommand((Constants
                                      .ADB_GET_PACKAGE_INFO_MAIN_ACTIVITY
                                      .replaceAll("package",
                                          "package ${Constants.currentPackageName}"))
                                  .split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_GET_PACKAGE_INFO_MAIN_ACTIVITY,
                                value);
                            showLog(result.mResult);
                          }).catchError((e) {
                            showLog(e.toString());
                          });
                        },
                        child: new Text("主Activity"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          runCommand(Constants.ADB_CURRENT_ACTIVITY.split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_CURRENT_ACTIVITY, value);
                            showLog(result.mResult);
                          }).catchError((e) {
                            showLog(e.toString());
                          });
                        },
                        child: new Text("当前Activity"))),
              ]),
              new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          if (Constants.currentPackageName.isEmpty) {
                            showLog("请先获取包名");
                            return;
                          }
                          runCommand(Constants.ADB_APK_PATH
                                  .replaceAll(
                                      "package", Constants.currentPackageName)
                                  .split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_APK_PATH, value);
                            showLog(result.mResult);
                          }).catchError((e) {
                            showLog(e.toString());
                          });
                        },
                        child: new Text("app安装路径"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          if (Constants.currentPackageName.isEmpty) {
                            showLog("请先获取包名");
                            return;
                          }
                          runCommand(Constants.ADB_CLEAR_DATA.split(" ")
                                ..add(Constants.currentPackageName))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_CLEAR_DATA, value);
                            showLog(result.mResult);
                          }).catchError((e) {
                            showLog(e.toString());
                          });
                        },
                        child: new Text("清除数据")))
              ]),
              SizedBox(
                height: 10,
              ),
              new Row(children: [
                new Text(
                  "应用信息：",
                  style: _tipTextStyle(),
                )
              ]),
              new Row(
                children: [
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: Constants.isInnerPackageName,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              if (isCheck!) {
                                Constants.isInnerPackageName = true;
                                Constants.isOuterApk = false;
                                setState(() {});
                              }
                            }),
                        new Text("内部包名")
                      ])),
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: Constants.isOuterApk,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              if (isCheck!) {
                                Constants.isInnerPackageName = false;
                                Constants.isOuterApk = true;
                                setState(() {});
                              }
                            }),
                        new Text("外部apk")
                      ])),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String aaptPath =
                                await FileUtils.getAaptToolsPath();
                            if (!await FileUtils.isExistFile(aaptPath)) {
                              showLog("$aaptPath 路径不存在");
                              return;
                            }
                            if (Constants.isInnerPackageName) {
                              if (Constants.currentPackageName.isEmpty) {
                                showLog("请先获取包名");
                                return;
                              }
                              String apkName =
                                  "${Constants.currentPackageName}.apk";
                              String apkPath = Constants.desktopPath +
                                  PlatformUtils.getSeparator() +
                                  apkName;
                              if (!await FileUtils.isExistFile(apkPath)) {
                                _aaptCommandByPackageName(
                                    apkPath, Constants.AAPT_GET_APK_INFO);
                              } else {
                                _aaptCommandByApk(
                                    apkPath, Constants.AAPT_GET_APK_INFO);
                              }
                            } else {
                              String? apkPath = await _selectFile(context,
                                  extensions: ["apk"]);
                              if (apkPath == null) {
                                showLog("未选择apk");
                                return;
                              }
                              _aaptCommandByApk(
                                  apkPath, Constants.AAPT_GET_APK_INFO);
                            }
                          },
                          child: new Text("apk基本信息"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String aaptPath =
                                await FileUtils.getAaptToolsPath();
                            if (!await FileUtils.isExistFile(aaptPath)) {
                              showLog("$aaptPath 路径不存在");
                              return;
                            }
                            if (Constants.isInnerPackageName) {
                              if (Constants.currentPackageName.isEmpty) {
                                showLog("请先获取包名");
                                return;
                              }
                              String apkName =
                                  "${Constants.currentPackageName}.apk";
                              String apkPath = Constants.desktopPath +
                                  PlatformUtils.getSeparator() +
                                  apkName;
                              if (!await FileUtils.isExistFile(apkPath)) {
                                _aaptCommandByPackageName(
                                    apkPath, Constants.AAPT_GET_APK_PERMISSION);
                              } else {
                                _aaptCommandByApk(
                                    apkPath, Constants.AAPT_GET_APK_PERMISSION);
                              }
                            } else {
                              String? apkPath = await _selectFile(context);
                              if (apkPath == null) {
                                showLog("未选择apk");
                                return;
                              }
                              _aaptCommandByApk(
                                  apkPath, Constants.AAPT_GET_APK_PERMISSION);
                            }
                          },
                          child: new Text("apk权限"))),
                ],
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
                            String name = "Activity";
                            String resultActivity = await showMutualAppDialog(
                                context,
                                await FileUtils.getMutualAppPath(name),
                                name);
                            if (resultActivity.isEmpty) {
                              showLog("无启动的Activity");
                            } else {
                              runCommand((Constants.ADB_START_ACTIVITY +
                                          resultActivity)
                                      .split(" "))
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_START_ACTIVITY, value);
                                if (!result.mError) {
                                  showLog("开启Activity成功：" + result.mResult);
                                } else {
                                  showLog("开启Activity失败：" + result.mResult);
                                }
                              }).catchError((error) {
                                showLog(error.toString());
                              });
                            }
                          },
                          child: new Text("启动Activity"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String name = "BroadcastReceiver";
                            String resultReceiver = await showMutualAppDialog(
                                context,
                                await FileUtils.getMutualAppPath(name),
                                name);
                            if (resultReceiver.isEmpty) {
                              showLog("发送空广播");
                              return;
                            }
                            runCommand((Constants.ADB_START_BROADCAST_RECEIVER +
                                        resultReceiver)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_START_BROADCAST_RECEIVER,
                                  value);
                              if (!result.mError) {
                                showLog("开启广播成功：" + result.mResult);
                              } else {
                                showLog("开启广播失败：" + result.mResult);
                              }
                            }).catchError((error) {
                              showLog(error.toString());
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
                            String name = "Service";
                            String resultService = await showMutualAppDialog(
                                context,
                                await FileUtils.getMutualAppPath(name),
                                name);
                            if (resultService.isEmpty) {
                              showLog("发送空Service");
                              return;
                            }
                            runCommand((Constants.ADB_START_SERVICE +
                                        resultService)
                                    .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_START_SERVICE, value);
                              if (!result.mError) {
                                showLog("开启Service成功：" + result.mResult);
                              } else {
                                showLog("开启Service失败：" + result.mResult);
                              }
                            }).catchError((error) {
                              showLog(error.toString());
                            });
                          },
                          child: new Text("发送Service"))),
                  Expanded(
                      child: new TextButton(
                          onPressed: () async {
                            String name = "Service";
                            String resultService = await showMutualAppDialog(
                                context,
                                await FileUtils.getMutualAppPath(name),
                                name);
                            if (resultService.isEmpty) {
                              showLog("停止空Service");
                              return;
                            }
                            runCommand(
                                    (Constants.ADB_STOP_SERVICE + resultService)
                                        .split(" "))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_STOP_SERVICE, value);
                              if (!result.mError) {
                                showLog("停止Service成功：" + result.mResult);
                              } else {
                                showLog("开停止Service失败：" + result.mResult);
                              }
                            }).catchError((error) {
                              showLog(error.toString());
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
                        showLog("未选择文件");
                      } else {
                        String pushPath = _checkPush == true
                            ? pushController.text
                            : "/data/local/tmp";
                        runCommand(
                                [Constants.ADB_PUSH_FILE, filePath, pushPath])
                            .then((value) {
                          result = command.dealWithData(
                              Constants.ADB_PUSH_FILE, value);
                          showLog(result.mResult);
                        }).catchError((e) {
                          showLog(e.toString());
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
                        new Text(
                          "自定义路径",
                          style: TextStyle(fontFamily: "simple"),
                        )
                      ])),
                  Expanded(
                      child: new TextField(
                    controller: pushController,
                    autofocus: false,
                    focusNode: _pushFocus,
                    decoration: InputDecoration(
                        labelText: "默认路径/data/local/tmp",
                        labelStyle: TextStyle(
                            fontFamily: "simple",
                            color: Colors.grey,
                            fontSize: 14)
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
                                  showLog(result.mResult);
                                } else {
                                  showLog("拉取成功");
                                }
                              }).catchError((e) {
                                showLog(e.toString());
                              });
                            } else {
                              showLog("请先点击点击收集crash");
                            }
                          } else {
                            if (currentPullPath.isEmpty) {
                              showLog("请先输入路径");
                              return;
                            }
                            if (currentPullFile.isEmpty) {
                              showLog("请先点击搜索该路径下的文件");
                              return;
                            } else {
                              runCommand(
                                [
                                  Constants.ADB_PULL_FILE,
                                  currentPullPath + "/" + currentPullFile
                                ],
                                workingDirectory: Constants.desktopPath,
                              ).then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_CRASH_FILE, value);
                                if (result.mError) {
                                  showLog(result.mResult);
                                } else {
                                  showLog("拉取成功");
                                }
                              }).catchError((e) {
                                showLog(e.toString());
                              });
                            }
                          }
                        },
                        child: new Text("拉取文件"))),
                Expanded(
                    child: TextButton(
                        onPressed: () {
                          runCommand(Constants.ADB_PULL_CRASH.split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_PULL_CRASH, value);
                            if (result.mError) {
                              showLog(result.mResult);
                            } else {
                              isPullCrash = true;
                              updatePull(result.mResult);
                            }
                          }).catchError((e) {
                            showLog(e.toString());
                          });
                        },
                        child: new Text("收集crash"))),
                Expanded(
                    child: TextButton(
                        onPressed: () {
                          runCommand([Constants.ADB_PULL_ANR],
                                  workingDirectory: Constants.desktopPath)
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_PULL_ANR, value);
                            showLog(result.mResult);
                          }).catchError((e) {
                            showLog(e.toString());
                          });
                        },
                        child: new Text("拉取anr"))),
              ]),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: new TextButton(
                          onPressed: () {
                            isPullCrash = false;
                            runCommand(Constants.ADB_SEARCH_ALL_FILE_PATH
                                    .split(" ")
                                  ..addAll([pullController.text]))
                                .then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_SEARCH_ALL_FILE_PATH, value);
                              if (result.mError) {
                                showLog(result.mResult);
                              } else {
                                isPullCrash = false;
                                updatePull(result.mResult);
                                currentPullPath = pullController.text;
                              }
                            }).catchError((e) {
                              showLog(e.toString());
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
                      hintStyle: TextStyle(
                          fontFamily: "simple",
                          color: Colors.grey,
                          fontSize: 14),
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                    onPressed: () async {
                      String uiToolPath = await FileUtils.getUIToolsPath();
                      if (!await FileUtils.isExistFolder(uiToolPath)) {
                        showLog("$uiToolPath 路径不存在,请手动配置");
                        return;
                      }
                      if (!await FileUtils.isExistFile(Constants.adbPath)) {
                        showLog("${Constants.adbPath}路径不存在");
                        return;
                      }
                      String commandStr = "";
                      if (Platform.isMacOS) {
                        commandStr = Constants.OPEN_UI_TOOL_MAC.replaceAll(
                            "adb_path", await FileUtils.getToolPath());
                      } else {
                        commandStr = Constants.OPEN_UI_TOOL.replaceAll(
                            "adb_path", await FileUtils.getToolPath());
                      }
                      showLog("执行命令：" + commandStr);
                      PlatformUtils.startCommand(commandStr,
                              runInShell: true, workDirectory: uiToolPath)
                          .then((value) {
                        var stream = value.stdout;
                        stream.listen((event) {
                          showLog(utf8.decode(event));
                        }, onError: (error) {
                          showLog("解析数据出错：" + error);
                        });
                        utf8.decodeStream(value.stderr).then((value) {
                          if (value.isNotEmpty) {
                            showLog("执行出错：" + value);
                          }
                        });
                      });
                    },
                    child: new Text("打开获取焦点工具")),
              ]),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      flex: 3,
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
                      flex: 2,
                      child: TextButton(
                        onPressed: () async {
                          simCommandPath = await _selectFile(context);
                          if (simCommandPath == null) {
                            showLog("未选择指令文件");
                          } else {
                            List<String>? commandsName =
                                await _analyseSimFile(simCommandPath!);
                            if (commandsName != null) {
                              updateSimOpName(commandsName);
                            }
                          }
                        },
                        child: new Text("添加指令文件"),
                      )),
                  Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () async {
                          if (simCommandPath == null) {
                            showLog("刷新失败");
                          } else {
                            List<String>? commandsName =
                                await _analyseSimFile(simCommandPath!);
                            if (commandsName != null) {
                              updateSimOpName(commandsName);
                            }
                          }
                        },
                        child: new Text("刷新指令文件"),
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
                            value: _lazyRandom,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              if (isCheck!) {
                                showLog("每条指令的时间采用设置时间的随机值");
                              }
                              setState(() {
                                _lazyRandom = isCheck;
                              });
                            }),
                        new Text("延迟随机")
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
                      _stopSimOperation();
                      if (Constants.currentSimOpName.isEmpty) {
                        showLog("请先添加模拟指令文件");
                        return;
                      }
                      if (_checkRepeat! || Constants.currentSimType == 0) {
                        String? times = await showSimDelayTimes(context);
                        if (times.isEmpty) {
                          return; //如果值为空，延迟默认为1s
                        }
                      }
                      _startSimOperation(
                          _checkAllDevice, _checkRepeat, _lazyRandom);
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
                  new Text("逆向相关：", style: _tipTextStyle()),
                ],
              ),
              new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () async {
                          showLog(" -f  强制覆盖存在  -r 不反编译资源文件  -s 不反编译代码");
                          String apkToolPath = await FileUtils.getApkToolPath();
                          if (!await FileUtils.isExistFile(apkToolPath)) {
                            showLog("$apkToolPath不存在,请手动配置");
                            return;
                          }
                          String? path =
                              await _selectFile(context, extensions: ["apk"]);
                          if (path == null) {
                            showLog("未选择apk");
                            return;
                          } else {
                            String commandExt = "${!_checkF! ? "" : "-f"}" +
                                "${!_checkR! ? "" : " -r"}" +
                                "${!_checkS! ? "" : " -s"}";
                            String commandStr = "";
                            if (commandExt.isEmpty) {
                              commandStr = Constants.APKTOOL_DECODE
                                  .replaceAll(" command", "")
                                  .replaceAll("ApkTool_path", apkToolPath)
                                  .replaceAll("Apk_path", path);
                            } else {
                              commandStr = Constants.APKTOOL_DECODE
                                  .replaceAll("command", commandExt)
                                  .replaceAll("ApkTool_path", apkToolPath)
                                  .replaceAll("Apk_path", path);
                            }
                            showLog("执行命令：$commandStr");
                            PlatformUtils.startCommand(commandStr,
                                    runInShell: true,
                                    workDirectory: Constants.desktopPath)
                                .then((value) {
                              var stream = value.stdout;
                              stream.listen((event) {
                                showLog(utf8.decode(event));
                              }, onError: (error) {
                                showLog("解析数据出错：" + error);
                              });
                              utf8.decodeStream(value.stderr).then((value) {
                                if (value.isNotEmpty) {
                                  showLog("执行出错：" + value);
                                }
                              });
                              value.exitCode
                                  .then((value) => {showLog("执行结束，退出码：$value")})
                                  .onError((error, stackTrace) =>
                                      {showLog("执行结束，出错：$error")});
                            });
                          }
                        },
                        child: new Text("Apktool拆包"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () async {
                          showLog(
                              " -f  强制覆盖存在  -d 添加debuggable=\"true\"到AndroidManifest文件");
                          String apkToolPath = await FileUtils.getApkToolPath();
                          if (!await FileUtils.isExistFile(apkToolPath)) {
                            showLog("$apkToolPath不存在,请手动配置");
                            return;
                          }
                          String? path =
                              await FilePicker.platform.getDirectoryPath();
                          if (path == null) {
                            showLog("文件夹不存在");
                            return;
                          } else {
                            String commandExt = "${!_checkF! ? "" : "-f"}" +
                                "${!_checkD! ? "" : " -d"}";
                            String commandStr = "";
                            if (commandExt.isEmpty) {
                              commandStr = Constants.APKTOOL_REBUILD
                                  .replaceAll(" command", "")
                                  .replaceAll("ApkTool_path", apkToolPath)
                                  .replaceAll("Apk_path", path)
                                  .replaceAll("new.apk",
                                      "${FileUtils.getDirName(path)}_new.apk");
                            } else {
                              commandStr = Constants.APKTOOL_REBUILD
                                  .replaceAll("command", commandExt)
                                  .replaceAll("ApkTool_path", apkToolPath)
                                  .replaceAll("Apk_path", path)
                                  .replaceAll("new.apk",
                                      "${FileUtils.getDirName(path)}_new.apk");
                            }
                            showLog("执行命令：$commandStr");
                            PlatformUtils.startCommand(commandStr,
                                    runInShell: true,
                                    workDirectory: Constants.desktopPath)
                                .then((value) {
                              var stream = value.stdout;
                              stream.listen((event) {
                                showLog(utf8.decode(event));
                              }, onError: (error) {
                                showLog("解析数据出错：" + error);
                              });
                              utf8.decodeStream(value.stderr).then((value) {
                                if (value.isNotEmpty) {
                                  showLog("执行出错：" + value);
                                }
                              });
                              value.exitCode
                                  .then((value) => {showLog("执行结束，退出码：$value")})
                                  .onError((error, stackTrace) =>
                                      {showLog("执行结束，出错：$error")});
                            });
                          }
                        },
                        child: new Text("Apktool合包")))
              ]),
              new Row(
                children: [
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkF,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              setState(() {
                                _checkF = isCheck;
                              });
                            }),
                        new Text("-f")
                      ])),
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkR,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              setState(() {
                                if (isCheck!) {
                                  _checkS = false;
                                }
                                _checkR = isCheck;
                              });
                            }),
                        new Text("-r") //不处理dex文件，--no-res
                      ])),
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkS,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              setState(() {
                                if (isCheck!) {
                                  _checkR = false;
                                }
                                _checkS = isCheck;
                              });
                            }),
                        new Text("-s") //不处理dex文件,--no-src
                      ])),
                  Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        new Checkbox(
                            value: _checkD,
                            activeColor: Colors.red,
                            onChanged: (isCheck) {
                              setState(() {
                                _checkD = isCheck;
                              });
                            }),
                        new Text("-d")
                        //添加debuggable="true"到AndroidManifest文件,--debug
                      ])),
                ],
              ),
              new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () async {
                          String fakerAndroidPath =
                              await FileUtils.getFakerAndroidPath();
                          if (!await FileUtils.isExistFile(fakerAndroidPath)) {
                            showLog("$fakerAndroidPath不存在,请手动配置");
                            return;
                          }
                          String? path =
                              await _selectFile(context, extensions: ["apk"]);
                          if (path == null) {
                            showLog("未选择apk");
                            return;
                          } else {
                            String commandStr =
                                Constants.Faker_Android.replaceAll(
                                        "Faker_Android_path", fakerAndroidPath)
                                    .replaceAll("Apk_path", path);
                            showLog("执行命令：$commandStr");
                            PlatformUtils.startCommand(commandStr,
                                    runInShell: true,
                                    workDirectory: Constants.desktopPath)
                                .then((value) {
                              var stream = value.stdout;
                              stream.listen((event) {
                                showLog(utf8.decode(event));
                              }, onError: (error) {
                                showLog("解析数据出错：" + error);
                              });
                              utf8
                                  .decodeStream(value.stderr)
                                  .then((value) => showLog("执行出错：" + value));
                              value.exitCode
                                  .then((value) => {showLog("执行结束，退出码：$value")})
                                  .onError((error, stackTrace) =>
                                      {showLog("执行结束，出错：$error")});
                            });
                          }
                        },
                        child: new Text("FakerAndroid")))
              ]),
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
                            runCommand([
                              Constants.ADB_REBOOT,
                            ]).then((value) {
                              result = command.dealWithData(
                                  Constants.ADB_REBOOT, value);
                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
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
                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
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
                              showLog(result.mResult);
                            }).catchError((e) {
                              showLog(e.toString());
                            });
                          },
                          child: new Text("重启到recovery"))),
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
                          runCommand(Constants.ADB_SCREEN_SHOT
                                  .replaceAll("shoot", pngName)
                                  .split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_SCREEN_SHOT, value);
                            if (!result.mError) {
                              showLog("截屏成功");
                              command
                                  .execCommand(
                                      Constants.ADB_PULL_SCREEN_SHOT
                                          .replaceAll("shoot", pngName)
                                          .split(" "),
                                      workingDirectory: Constants.desktopPath)
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_SCREEN_SHOT, value);
                                showLog(result.mResult);
                              });
                            } else {
                              showLog(result.mResult);
                            }
                          }).catchError((e) {
                            showLog(e.toString());
                          });
                        },
                        child: new Text("截屏"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () async {
                          String times = await showScreenRecordDialog(context);
                          if (times.isEmpty) {
                            return;
                          }
                          String recordName = TimeUtils.getCurrentTimeFormat();
                          runCommand(Constants.ADB_SCREEN_RECORD
                                  .replaceAll("times", times)
                                  .replaceAll("record_screen", recordName)
                                  .split(" "))
                              .then((value) {
                            result = command.dealWithData(
                                Constants.ADB_SCREEN_RECORD, value);
                            if (!result.mError) {
                              showLog("录屏结束");
                              runCommand(
                                      Constants.ADB_PULL_SCREEN_RECORD
                                          .replaceAll(
                                              "record_screen", recordName)
                                          .split(" "),
                                      workingDirectory: Constants.desktopPath)
                                  .then((value) {
                                result = command.dealWithData(
                                    Constants.ADB_PULL_SCREEN_RECORD, value);
                                showLog(result.mResult);
                              });
                            } else {
                              showLog(result.mResult);
                            }
                          }).catchError((e) {
                            showLog(e.toString());
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
                            if (apkPath == null) {
                              showLog("未选择Apk文件");
                              return;
                            }
                            if (!await FileUtils.isExistFile(
                                Constants.signerPath.path)) {
                              showLog("apksigner签名文件不存在");
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
                                  .replaceAll("outapk",
                                      "${FileUtils.getDirName(apkPath)}_signer.apk")
                                  .replaceAll("inputapk", apkPath);
                              PlatformUtils.runCommand(commandStr,
                                      workDirectory: Constants.desktopPath)
                                  .then((value) {
                                if (value.stderr.toString().isEmpty) {
                                  showLog("签名成功");
                                } else {
                                  showLog(value.stderr.toString());
                                }
                              }).catchError((e) {
                                showLog(e.toString());
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
                        showLog("apksigner签名文件不存在");
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
                            showLog(value.stdout);
                          } else {
                            showLog(value.stderr);
                          }
                        }).catchError((e) {
                          showLog(e.toString());
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
final TextEditingController javaController = new TextEditingController();
final TextEditingController libDeviceController = new TextEditingController();

final TextEditingController editorController = new TextEditingController();
final TextEditingController apkSignerController = new TextEditingController();

final TextEditingController wireLessController = new TextEditingController();
final TextEditingController pushController = new TextEditingController();
final TextEditingController pullController = new TextEditingController();
final TextEditingController simOpTimeController =
    new TextEditingController(text: "1000"); //默认1000毫米
final TextEditingController screenRecordController =
    new TextEditingController();

bool isPullCrash = false; //当前需要拉取普通文件还是crash文件

showSettingDialog(BuildContext context) {
  showDialog(
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
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () {
                    if (adbController.text.isEmpty &&
                        javaController.text.isEmpty &&
                        libDeviceController.text.isEmpty) {
                      Navigator.of(context).pop();
                      return;
                    }
                    _settings[Constants.outerKey] = adbController.text;
                    _settings[Constants.javaKey] = javaController.text;
                    _settings[Constants.libDeviceKey] =
                        libDeviceController.text;
                    if (!Constants.isInnerAdb) {
                      Constants.adbPath = adbController.text;
                      _getAdbVersion();
                    }
                    Constants.javaPath = javaController.text;
                    Constants.outerAdbPath = adbController.text;
                    Constants.libDevicePath = libDeviceController.text;
                    FileUtils.writeSetting(_settings);
                    Navigator.of(context).pop();
                  },
                )
              ],
              title: new Text("设置", style: new TextStyle(fontSize: 20)),
              content: new Center(
                  child: new Container(
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
                                        showLog("未选择adb文件");
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
                            new SizedBox(
                              height: 10,
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new TextButton(
                                    onPressed: () async {
                                      String? path = await _selectFile(context);
                                      if (path == null) {
                                        showLog("未选择java文件");
                                      } else {
                                        javaController.text = path;
                                      }
                                    },
                                    child: new Text("java")),
                                new Expanded(
                                    child: TextField(
                                  controller: javaController,
                                  decoration: InputDecoration(
                                    enabled: false,
                                    labelText: 'java',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            new SizedBox(
                              height: 10,
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new TextButton(
                                    onPressed: () async {
                                      String? path = await FilePicker.platform
                                          .getDirectoryPath();
                                      if (path == null) {
                                        showLog("未选择libimobiledevice文件夹");
                                      } else {
                                        libDeviceController.text = path;
                                      }
                                    },
                                    child: new Text("libimobiledevice")),
                                new Expanded(
                                    child: TextField(
                                  controller: libDeviceController,
                                  decoration: InputDecoration(
                                    enabled: false,
                                    labelText: 'libimobiledevice',
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

///展示交互APP的弹窗
Future<String> showMutualAppDialog(
    BuildContext context, String filePath, String name,
    {String tips = ""}) async {
  if (tips == "") {
    showTips = "文件路径：" + PlatformUtils.getLineBreak() + filePath;
  } else {
    showTips = "文件路径：" +
        PlatformUtils.getLineBreak() +
        filePath +
        PlatformUtils.getLineBreak() +
        tips;
  }
  await updateState(filePath);
  var result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, state) {
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
                        Navigator.of(context).pop(currentMutualApp);
                      },
                    ),
                    TextButton(
                      child: Text('编辑'),
                      onPressed: () async {
                        bool result = await showEditor(context, filePath, name);
                        if (result) {
                          await updateState(filePath);
                          state(() {});
                        }
                      },
                    ),
                    TextButton(
                      child: Text('刷新'),
                      onPressed: () async {
                        await updateState(filePath);
                        state(() {});
                      },
                    ),
                    TextButton(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop("");
                      },
                    )
                  ],
                  title: new Text(name, style: new TextStyle(fontSize: 20)),
                  content: new Center(
                      child: new Container(
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
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        child: DropdownButton<String?>(
                                      isExpanded: true,
                                      value: currentMutualApp,
                                      onChanged: (String? newValue) {
                                        state(() {
                                          if (newValue != null) {
                                            currentMutualApp = newValue;
                                          }
                                        });
                                      },
                                      items: mutualAppDdmi,
                                    )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: new SelectableText(
                                        showTips,
                                        maxLines: null,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.red),
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
          },
        );
      });
  return result;
}

Future updateState(String filePath) async {
  mutualAppDdmi.clear();
  List<String> fileList = await FileUtils.readFileByLine(filePath);
  if (fileList.length > 0) {
    currentMutualApp = fileList[0];
    fileList.toSet().forEach((element) {
      mutualAppDdmi.add(new DropdownMenuItem(
        child: new Text(
          element,
          style: _dropDownTextStyle(),
        ),
        value: element,
      ));
    });
  } else {
    currentMutualApp = "";
  }
}

Future<bool> showEditor(BuildContext context, String path, String name) async {
  String content = await FileUtils.readFile(File(path));
  editorController.text = content;
  bool result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return UnconstrainedBox(
          child: SizedBox(
            child: new AlertDialog(
              scrollable: true,
              actions: [
                TextButton(
                  child: Text('确定'),
                  onPressed: () async {
                    Set<String> textSet = {};
                    String value = "";
                    if (editorController.text.isNotEmpty &&
                        editorController.text != content) {
                      List<String> text = editorController.text.split("\n");
                      text.insert(0, text[text.length - 1]);
                      text.removeAt(text.length - 1);
                      textSet = text.toSet();
                      textSet.forEach((element) {
                        value += element +
                            "${element == text[text.length - 1] ? "" : "\n"}";
                      });
                      await FileUtils.writeFile(value, File(path));
                    }
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                )
              ],
              title: new Text("$name编辑", style: new TextStyle(fontSize: 20)),
              content: new Center(
                  child: new Container(
                      //color: Color.fromARGB(255, 250, 255, 0),
                      width: 0.5 * _width,
                      height: 0.5 * _height,
                      child: new SingleChildScrollView(
                        child: new Column(
                          children: [
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new Expanded(
                                    child: TextField(
                                  controller: editorController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  //不限制行数
                                  enabled: true,
                                  autofocus: false,
                                  enableInteractiveSelection: true,

                                  decoration: InputDecoration(
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
                ),
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop("");
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
                      showLog("时间不能设置为空");
                      return;
                    }
                    Navigator.of(context).pop(screenRecordController.text);
                  },
                ),
                TextButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop("");
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
                                    FilteringTextInputFormatter.digitsOnly
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
    showLog("文本开始必须以0或者1");
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
        showLog("滑动指令格式不对,正确格式swipe x1 y1 x2 y2 name");
        return null;
      }
    } else if (commands[i].startsWith("tap")) {
      List<String> commandTap = commands[i].split(" ");
      if (commandTap.length >= 4) {
        simCommand.add(
            Constants.ADB_SIM_TAP + " " + commandTap[1] + " " + commandTap[2]);
        simCommandName.add(commandTap[3]);
      } else {
        showLog("点击指令格式不对,正确格式tap x1 y1 name");
        return null;
      }
    } else if (commands[i].startsWith("text")) {
      List<String> commandText = commands[i].split(" ");
      if (commandText.length >= 3) {
        simCommand.add(Constants.ADB_SIM_INPUT + " " + commandText[1]);
        simCommandName.add(commandText[2]);
      } else {
        showLog("输入文字指令格式不对,正确格式text 文本内容 name");
        return null;
      }
    } else if (commands[i].startsWith("event")) {
      //输入的是键值
      List<String> commandKeyCode = commands[i].split(" ");
      if (commandKeyCode.length >= 3) {
        simCommand.add(Constants.ADB_SIM_KEY_EVENT + " " + commandKeyCode[1]);
        simCommandName.add(commandKeyCode[2].toLowerCase());
      } else {
        showLog("键值指令格式不对,正确格式event 键值 name");
        return null;
      }
    } else if (commands[i].startsWith("adb")) {
      //其他adb指令
      List<String> commandKeyCode = commands[i].split(" ");
      if (commandKeyCode.length >= 3) {
        String command = "";
        for (int i = 0; i < commandKeyCode.length; i++) {
          if (i != 0 && i != commandKeyCode.length - 1) {
            command += commandKeyCode[i] + " ";
          }
        }
        simCommand.add(command.trim());
        simCommandName
            .add(commandKeyCode[commandKeyCode.length - 1].toLowerCase());
      } else {
        showLog("其他adb指令格式不对,,正确格式adb 指令 name");
        return null;
      }
    } else if (commands[i].startsWith("other")) {
      //其他adb指令
      List<String> commandKeyCode = commands[i].split(" ");
      if (commandKeyCode.length >= 3) {
        String command = "";
        for (int i = 0; i < commandKeyCode.length; i++) {
          if (i != 0 && i != commandKeyCode.length - 1) {
            command += commandKeyCode[i] + " ";
          }
        }
        simCommand.add(command.trim());
        simCommandName.add(
            "other_" + commandKeyCode[commandKeyCode.length - 1].toLowerCase());
      } else {
        showLog("非adb指令格式不对,,正确格式other 指令 name");
        return null;
      }
    } else {
      showLog("当前指令不支持，不满足条件");
      return null;
    }
  }
  if (commands[0] == "0") {
    Constants.currentSimType = 0;
    //simCommandName.clear();
    //simCommandName.add(path.split(PlatformUtils.getSeparator()).last);
    return [path.split(PlatformUtils.getSeparator()).last];
  } else if (commands[0] == "1") {
    Constants.currentSimType = 1;
    return simCommandName;
  }
  return simCommandName;
}

bool _opRepeat = false;
bool _lazyRandom = false;

void _startSimOperation(
    bool? checkAllDevice, bool? checkRepeat, bool? lazyRandom) {
  _opRepeat = checkRepeat == true;
  _lazyRandom = lazyRandom == true;
  List<String> listDevices = [];
  if (checkAllDevice == true) {
    if (currentAllDevice.length == 0) {
      listDevices.add("");
    } else {
      listDevices..addAll(currentAllDevice);
    }
  } else {
    if (Constants.currentDevice.isEmpty) {
      listDevices.add("");
    } else {
      listDevices.add(Constants.currentDevice);
    }
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

int getRandom(int min, int max) {
  int random = min + Random().nextInt(max - min);
  return random;
}

_runCommand(List<String> listOps, String device) {
  List<Future> futureList = [];
  int delay = int.parse(simOpTimeController.text);
  for (int i = 0; i < listOps.length; i++) {
    int randomTime = 0;
    //2种情况不随机延迟
    //1、当前是单条指令并且不重复
    //2、未开启指令随机
    if (Constants.currentSimType == 1 && !_opRepeat || !_lazyRandom) {
      randomTime = delay * (i + 1);
    } else {
      randomTime = getRandom(delay * i, delay * (i + 1));
    }
    futureList.add(Future.delayed(Duration(milliseconds: randomTime), () {
      List<String> arguments = listOps[i].split(" ");
      showLog("延迟时间：${randomTime - delay * i}ms");
      if (!simCommandName[simCommand.indexOf(listOps[i])].startsWith("other")) {
        if (device.isNotEmpty) {
          arguments = ["-s", device]..addAll(arguments);
        }
        showLog("执行指令：adb:${Constants.adbPath},arguments:$arguments");
        Process.run(Constants.adbPath, arguments).then((value) {
          showLog("执行结束：" + value.stdout + value.stderr);
        }).catchError((e) {
          showLog("执行出错：");
        });
      } else {
        showLog("执行指令：arguments:$arguments");
        PlatformUtils.runCommand(listOps[i]).then((value) {
          showLog("执行结束：" + value.stdout + value.stderr);
        }).catchError((e) {
          showLog("执行出错：");
        });
      }
    }));
  }

  Future.wait(futureList).then((value) {
    if (_opRepeat) {
      _runCommand(listOps, device);
    } else {
      showLog("停止模拟指令");
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

//每次都定位到最后一行
//移动光标位置到最后
// _logTextController.selection = TextSelection.fromPosition(
//     TextPosition(offset: _logTextController.text.length));
// FocusScope.of(leftPanelState.context).requestFocus(leftPanelFocus);
// //延迟移除光标闪烁
void showLog(String msg) {
  if (msg.isEmpty) {
    return;
  }
  if (showLogText.isEmpty) {
    showLogText = ">>>>>>>" + showLogText + msg.trim();
  } else {
    showLogText = showLogText + "\n" + ">>>>>>>" + msg.trim();
  }
  _logTextController.text = showLogText;
  Future.delayed(Duration(milliseconds: 200), () {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, //滚动到底部
      //滚动到底部
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    //FocusScope.of(leftPanelState.context).requestFocus(leftPanelFocus);
  });
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

void _aaptCommandByPackageName(String apkPath, String commandStr) {
  if (commandStr.contains("grep")) {
    commandStr = commandStr.replaceAll("grep", PlatformUtils.grepFindStr());
  }
  runCommand(Constants.ADB_APK_PATH
          .replaceAll("package", Constants.currentPackageName)
          .split(" "))
      .then((value) {
    result = command.dealWithData(Constants.ADB_APK_PATH, value);
    String apkInnerPath = result.mResult;
    runCommand(
      [Constants.ADB_PULL_FILE, apkInnerPath, apkPath],
    ).then((value) {
      result = command.dealWithData(Constants.ADB_PULL_FILE, value);
      if (result.mError) {
        showLog(result.mResult);
      } else {
        showLog(result.mResult);
        if (result.mResult.toString().contains("error")) {
          showLog(result.mResult);
        } else {
          _aaptCommandByApk(apkPath, commandStr);
        }
      }
    }).catchError((e) {
      showLog(e.toString());
    });
  }).catchError((e) {
    showLog(e.toString());
  });
}

void _aaptCommandByApk(String apkPath, String commandStr) async {
  if (commandStr.contains("grep")) {
    commandStr = commandStr.replaceAll("grep", PlatformUtils.grepFindStr());
  }
  String aaptPath = await FileUtils.getAaptToolsPath();
  PlatformUtils.runCommand(
    commandStr.replaceAll("aapt", aaptPath).replaceAll("apk", apkPath),
  ).then((value) {
    result = command.dealWithData(commandStr, value);
    if (result.mError) {
      showLog(result.mResult);
    } else {
      showLog(result.mResult);
    }
  }).catchError((e) {
    showLog(e.toString());
  });
}

void _getAdbVersion() {
  runCommand([Constants.ADB_VERSION]).then((value) {
    result = command.dealWithData(Constants.ADB_VERSION, value);
    showLog(result.mResult);
  }).catchError((error) {
    showLog(error.toString());
  });
}

Future<ProcessResult> runCommand(List<String> arguments,
    {String executable = "",
    String? workingDirectory,
    bool runInShell = false}) {
  showLog(
      "执行命令：${executable.isEmpty ? Constants.adbPath : executable} ${Constants.currentDevice.isNotEmpty ? "-s ${Constants.currentDevice}" : ""} ${_convertList(arguments)}");
  return command.execCommand(arguments,
      executable: executable,
      workingDirectory: workingDirectory,
      runInShell: runInShell);
}

String _convertList(List<String> arguments) {
  String argu = "";
  arguments.forEach((element) {
    argu += element + " ";
  });
  return argu;
}

TextStyle _dropDownTextStyle({double fontTextSize = 12}) {
  return TextStyle(fontSize: fontTextSize, color: Colors.black);
}

TextStyle _tipTextStyle() {
  return TextStyle(
      fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold);
}
