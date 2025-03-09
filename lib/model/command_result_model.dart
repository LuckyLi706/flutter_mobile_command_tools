/// 命令的输出结果
class CommandResultModel<T> {
  bool isSuccess = false;
  T? data;
  String error = "";

  CommandResultModel(this.isSuccess, this.data);

  CommandResultModel.error(this.isSuccess, this.data, this.error);

  @override
  String toString() {
    return 'CommandResultModel{isSuccess: $isSuccess, data: $data}';
  }
}
