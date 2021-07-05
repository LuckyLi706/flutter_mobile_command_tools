# MobileTool
最近没事学习了一波flutter，移动端没想到写啥。就写了一个桌面端应用。也是之前项目的一个衍生。之前用c#写过一个使用adb操作Android手机的windows应用，主要就是为了简化操作。现在把这个功能转移到所有桌面应用来，并且修复之前的一些遗留的BUG

## 功能
### Android
+ 获取设备
获取当前所有连接的Android设备，展示在下拉框里面（大部分功能都需要先获取设备）
+ 获取应用包名
获取当前展示在前台的包名（清除数据和卸载apk功能需要获取）
+ 当前activity
展示当前顶级activity
+ 清除数据
清除当前获取包名的数据
+ 截屏
截取当前设备的界面，并且推送到桌面（命名screen.png）
+ 录屏
录取当前屏幕，需要先设置时间，完成后推送到桌面（命名record.mp4）
+ 安装apk
选择apk然后安装到当前设备上
+ 卸载apk
卸载当前获取包名的apk
+ 无线连接
选择真机，非自定义的情况下会去获取当前真机的ip，获取成功直接去连接，获取失败，需要自定义去填入ip:port。选择其他模拟器设备，默认内置了所有模拟器的第一台设备的端口。
+ 断开
只能断开无线连接的设备和模拟器
+ push
选择文件推送到当前设备，默认推送位置/data/local/tmp。可以自定义位置
+ 拉取文件
从当前设备拉取文件到桌面，如果一开始选择了手机crash，选择对应的时间点拉取crash。如果需要拉取文件，需要先配置搜索的文件路径，然后点击手机，然后再点击拉取文件。
+ 模拟操作的执行命令
目前模拟操作集成了输入、滑动、点击、后退。根据选择的不同来执行模拟操作。
+ v2签名
使用apksigner的签名。windows的签名文件放在apksigner文件夹下面，macos放在/Users/用户名/Library/Caches/apksigner下面，可以进行替换，保证文件名一样。
### IOS
暂时未做（计划使用libmobileinstaller的相关指令）

## 编译
所有平台应用都改成了占当前屏幕的2/3，居中显示。
+ windows
需要安装Visual Studio,选择c++依赖。
flutter build windows 进行编译。在build/windows/runner 会生成Visual Studio的解决方案工程。可以导入进行开发。
exe在build/windows/runner/Release/*.exe

## 截图展示
+ windows（1920*1080）
![screenshots/windows.png](screenshots/windows.png)

+ linux (1920*1080)
![screenshots/linux.png](screenshots/linux.png)