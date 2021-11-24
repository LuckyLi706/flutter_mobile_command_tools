import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/command/Command.dart';
import 'package:flutter_mobile_command_tools/main.dart' as app;
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/utils/FileUtils.dart';
import 'package:flutter_mobile_command_tools/utils/LogUtils.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

import '../constants.dart';

class IOSRightPanel extends StatefulWidget {
  @override
  IOSRightPanelState createState() => IOSRightPanelState();
}

String deviceInstallPath = "";
String devicePackagePath = "";

IOSCommand iosCommand = IOSCommand();

List<DropdownMenuItem<String>> connectDeviceDdmi = []; //获取设备下拉框的列表
List<DropdownMenuItem<String>> allPackageNameDdmi = []; //获取设备下拉框的列表

ScrollController scrollController = new ScrollController();

class IOSRightPanelState extends State<IOSRightPanel> {
  void updateDevice(List<String> resultList) {
    setState(() {
      connectDeviceDdmi.clear();
      if (resultList.length > 0) {
        Constants.currentIOSDevice = resultList[0];
        resultList.toSet().forEach((element) {
          connectDeviceDdmi.add(new DropdownMenuItem(
            child: new Text(
              element,
              style: _dropDownTextStyle(fontTextSize: 14),
            ),
            value: element,
          ));
        });
      } else {
        Constants.currentIOSDevice = "";
      }
    });
  }

  void updatePackageName(List<String> resultList) {
    setState(() {
      allPackageNameDdmi.clear();
      if (resultList.length > 0) {
        Constants.currentIOSPackageName = resultList[0];
        resultList.toSet().forEach((element) {
          allPackageNameDdmi.add(new DropdownMenuItem(
            child: new Text(
              element,
              style: _dropDownTextStyle(fontTextSize: 14),
            ),
            value: element,
          ));
        });
      } else {
        Constants.currentIOSPackageName = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        child: new Column(
          children: [
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
                        onPressed: () async {
                          if (Constants.libDevicePath.isEmpty ||
                              !await FileUtils.isExistFolder(
                                  Constants.libDevicePath)) {
                            app.showLog("libimobiledevice目录不存在");
                          } else {
                            deviceInstallPath = Constants.libDevicePath +
                                PlatformUtils.getSeparator() +
                                "idevice_id";
                            iosCommand.execCommand([Constants.IOS_GET_DEVICE],
                                executable: deviceInstallPath).then((value) {
                              var result = iosCommand.dealWithData(
                                  Constants.IOS_GET_DEVICE, value);
                              if (result.mError) {
                                updateDevice([]);
                                app.showLog(result.mResult);
                              } else {
                                updateDevice(result.mResult);
                              }
                              // ignore: invalid_return_type_for_catch_error
                            }).catchError((error) => print(error));
                          }
                        },
                        child: new Text("获取设备"))),
                Expanded(
                    child: DropdownButton<String>(
                  isExpanded: true,
                  value: Constants.currentIOSDevice,
                  onChanged: (String? newValue) {
                    setState(() {
                      Constants.currentIOSDevice =
                          newValue == null ? "" : newValue;
                    });
                  },
                  items: connectDeviceDdmi,
                )),
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
                  value: Constants.currentIOSPackageName,
                  onChanged: (String? newValue) {
                    setState(() {
                      Constants.currentIOSPackageName =
                          newValue == null ? "" : newValue;
                      app.showLog(Constants.mapIOSInfo[newValue!]!);
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
                          devicePackagePath = Constants.libDevicePath +
                              PlatformUtils.getSeparator() +
                              "ideviceinstaller";
                          iosCommand
                              .execCommand(
                                  Constants.IOS_GET_THIRD_PACKAGE.split(" "),
                                  executable: devicePackagePath)
                              .then((value) {
                            CommandResult result = iosCommand.dealWithData(
                                Constants.IOS_GET_THIRD_PACKAGE, value);
                            if (result.mError) {
                              updatePackageName([]);
                              app.showLog(result.mResult);
                            } else {
                              updatePackageName(result.mResult);
                              app.showLog("第三方应用所有包名获取成功");
                              app.showLog(Constants.mapIOSInfo[Constants.currentIOSPackageName]!);
                            }
                          }).catchError((e) {
                            updatePackageName([]);
                            app.showLog(e.toString());
                          });
                        },
                        child: new Text("第三方包名"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          devicePackagePath = Constants.libDevicePath +
                              PlatformUtils.getSeparator() +
                              "ideviceinstaller";
                          iosCommand
                              .execCommand(
                                  Constants.IOS_GET_SYSTEM_PACKAGE.split(" "),
                                  executable: devicePackagePath)
                              .then((value) {
                            CommandResult result = iosCommand.dealWithData(
                                Constants.IOS_GET_SYSTEM_PACKAGE, value);
                            if (result.mError) {
                              updatePackageName([]);
                              app.showLog(result.mResult);
                            } else {
                              updatePackageName(result.mResult);
                              app.showLog("系统应用所有包名获取成功");
                              app.showLog(Constants.mapIOSInfo[Constants.currentIOSPackageName]!);
                            }
                          }).catchError((e) {
                            updatePackageName([]);
                            app.showLog(e.toString());
                          });
                        },
                        child: new Text("系统包名"))),
              ],
            ),
            new Row(
              children: [
                Expanded(
                    child: new TextButton(
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowMultiple: false,
                            allowedExtensions: ['ipa'],
                          );

                          if (result == null) {
                            app.showLog("未选择文件");
                            return;
                          }

                          devicePackagePath = Constants.libDevicePath +
                              PlatformUtils.getSeparator() +
                              "ideviceinstaller";
                          iosCommand
                              .execCommand(
                                  Constants.IOS_INSTALL_APP
                                      .replaceAll("*.ipa", result.paths[0]!)
                                      .split(" "),
                                  executable: devicePackagePath)
                              .then((value) {
                            CommandResult result = iosCommand.dealWithData(
                                Constants.IOS_INSTALL_APP, value);
                            if (result.mError) {
                              app.showLog(result.mResult);
                            } else {
                              app.showLog("安装成功");
                            }
                          }).catchError((e) {
                            app.showLog(e.toString());
                          });
                        },
                        child: new Text("安装应用"))),
                Expanded(
                    child: new TextButton(
                        onPressed: () {
                          if (Constants.currentIOSPackageName.isEmpty) {
                            app.showLog("请先获取App包名");
                            return;
                          }
                          devicePackagePath = Constants.libDevicePath +
                              PlatformUtils.getSeparator() +
                              "ideviceinstaller";
                          iosCommand
                              .execCommand(
                                  Constants.IOS_UNINSTALL_APP
                                      .replaceAll("bundleID",
                                          Constants.currentIOSPackageName)
                                      .split(" "),
                                  executable: devicePackagePath)
                              .then((value) {
                            CommandResult result = iosCommand.dealWithData(
                                Constants.IOS_UNINSTALL_APP, value);
                            if (result.mError) {
                              app.showLog(result.mResult);
                            } else {
                              app.showLog("卸载成功");
                              LogUtils.printLog(result.mResult);
                            }
                          }).catchError((e) {
                            updatePackageName([]);
                            app.showLog(e.toString());
                          });
                        },
                        child: new Text("卸载应用"))),
              ],
            ),
          ],
        ));
  }
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
