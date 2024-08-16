class CommandResultModel {
  bool isSuccess = false;
  dynamic data;

  CommandResultModel(this.isSuccess, this.data);

  @override
  String toString() {
    return 'CommandResultModel{isSuccess: $isSuccess, data: $data}';
  }
}
