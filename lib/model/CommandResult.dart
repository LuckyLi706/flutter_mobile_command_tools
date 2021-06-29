class CommandResult {
  bool _error = false;
  dynamic _result;

  set mResult(dynamic result) => _result = result;

  dynamic get mResult => _result;

  set mError(bool error) => _error = error;

  bool get mError => _error;
}
