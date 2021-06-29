class SettingModel {
  String adb = "";

  SettingModel(String adb) {
    this.adb = adb;
  }

  SettingModel.fromJson(Map<String, dynamic> json) : adb = json['adb'];

  Map<String, dynamic> toJson() => {
        'adb': adb,
      };
}
