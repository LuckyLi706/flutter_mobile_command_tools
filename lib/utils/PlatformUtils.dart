import 'dart:io';

class PlatformUtils{
  static String getLineBreak(){
    if(Platform.isWindows){
      return "\r\n";
    }else{
      return "\n";
    }
  }
}