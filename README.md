# MobileTool
最近没事学习了一波flutter，移动端没想到写啥。就写了一个桌面端应用。也是之前项目的一个衍生。之前用c#写过一个使用adb操作Android手机的windows应用，主要就是为了简化操作。现在把这个功能转移到所有桌面应用来，并且修复之前的一些遗留的BUG。

如果有其他adb功能需要添加的可以提。

## 说明

+ 关于Android

  请自行打开手机开发者模式中的USB调试，确保手机和电脑能连接上。确保能使用adb连接上，本工具Android模块只是将adb的大部分命令进行了懒人模式，有问题欢迎提issues。

## 功能

### Android

+ 开启Root
  
  如果手机又Root权限，可以打开，在获取信息的时候使用到。如果手机有Magisk，可以安装这个插件[adb_root](https://github.com/evdenis/adb_root)，可以让所有的命令都走root权限。

+ 内置ADB
  
  如果你的电脑没有adb，打开这个开关会使用内置的adb。如果你电脑本身有adb，点击右上角的配置，配置adb路径，以免内置的adb和你安装的adb冲突。

  - 外部ADB路径设置
  
    ![](screenshots/settings.png)
  
+ 基本操作
  
  - 获取设备
  
    获取当前所有连接的Android设备，展示在下拉框里面（大部分功能都需要先获取设备）
  
  - 获取设备信息
  
    选择，然后点击获取信息，部分信息在高版本的手机上面需要Root权限
  
+ 无线连接

  - 无线连接

    选择真机，非自定义的情况下会去获取当前真机的ip，获取成功直接去连接，获取失败，需要自定义去填入ip:port。选择其他模拟器设备，默认内置了所有模拟器的第一台设备的端口。然后点击无线连接就ok了。

  - 断开
    只能断开无线连接的设备和模拟器

+ 应用管理

  + 当前包名

    获取当前展示的app包名，展示在上面的下拉框里面。

  + 第三方包名（新增）

    获取当前所有第三方的app包名，展示在上面的下拉框里面。

  + 系统包名（新增）

    获取当前所有系统的app包名，展示在上面的下拉框里面。

  + 安装apk

    选择本地的apk文件安装到手机上面

  + 卸载apk

    卸载当前获取到包名的apk。

  + apk路径

    当前获取到包名的app路径。

  + app包信息（新增）

    当前获取到包名的app信息，可以复制部分信息为应用交互做准备。

  + 前台Activity

    当前最顶级的Activity名。

  + 清楚数据

    清楚当前获取到包名的数据。

+ 应用交互（新增）

  - 启动Activity

    弹窗输入要启动的Activity名字，如果没有输入将启动当前获取包名的app。（关于启动类可以通过app包信息获取）

  - 发送BroadcastReceiver

    弹窗输入要启动的广播，下面也列出了部分系统广播，用于测试很难出现的光比。

  - 发送Service

    弹出输入要启动的Service

  - 停止Service

    弹出输入要通知的Service

+ 文件管理

  - 推送文件
    选择文件推送到当前设备，默认推送位置/data/local/tmp。点击自定义路径，可以输入你想推送的路径。

  + 拉取文件
    从当前设备拉取文件到桌面。

    1. 手机crash

       点击手机crash，将收集所有crash日志，展示出来，然后选择时间点点击拉取crash。会推送到桌面

    2. 拉取文件

       只是为了拉取文件。需要先配置搜索的文件路径，然后点击搜索，会搜索该路径下的所有文件。然后再点击拉取文件。也会推送到桌面。

    3. 拉取anr

       直接点击，会直接拉取anr日志到桌面（时间有点长，耐心等待）

+ 模拟操作

  目前模拟操作集成了输入、滑动、点击、后退。根据选择的不同来执行模拟操作。

+ 实用操作

  + 截屏（修改）
    截取当前设备的界面，并且推送到桌面（命名 当前时间.png）

  + 录屏（修改）
    录取当前屏幕，需要先设置时间，完成后推送到桌面（命名 当前时间.mp4）

  + 重启手机

    重新启动手机

  + 重启到fastboot

    重启手机到fastboot模式

  + 重启到recovery

    重启手机到recovery模式

  + v2签名
    使用apksigner的签名。windows的签名文件放在apksigner文件夹下面，macos放在/Users/用户名/Library/Caches/apksigner下面，可以进行替换，保证文件名一样。apksigner.json为签名的key以及密码。替换记得修改。

### IOS
暂时未做（计划使用libmobileinstaller的相关指令）

## 编译
所有平台应用都改成了占当前屏幕的2/3，采用居中显示，linux没有居中，GTK没搞过。
+ windows

  ```
  安装Visual Studio,c++桌面包。
  flutter build windows  //进行编译。
  在build/windows/runner 会生成Visual Studio的解决方案工程，可以导入进行开发。
  生成的exe在build/windows/runner/Release/*.exe
  ```

+ linux

  ```
  //linux需要安装以下依赖
  sudo apt-get update
  sudo apt install clang
  sudo apt install cmake
  sudo apt install ninja-build
  sudo apt install libgtk-3-dev
  
  
  file INSTALL cannot copy file  //出现这个问题
  flutter clean  //执行这个然后重启AndroidStudio
  
  flutter build linux //生成release包,文件在build/linux/release/bundle下面

  ```

+ macos

  ```
  安装Xcode，然后在编译的时候遇到很多小问题。然后百度解决了，其中一个
  [tool_crash] Invalid argument(s): Cannot find executable for /Users/imac/Documents/FlutterSDK/flutter/bin/cache/artifacts
  解决方案：https://github.com/flutter/flutter/issues/85107
  
  flutter build macos //生成release包,文件在build/macos/Build/Products/Release/下面
  将mac目录下的文件倒入xcode可进行开发
  ```
  

## 截图展示
+ windows（1920*1080）
![screenshots/windows.png](screenshots/windows.png)

+ linux (1920*1080)
![screenshots/linux.png](screenshots/linux.png)

+ macos (1440*960)
![screenshots/macos.png](screenshots/macos.png)
