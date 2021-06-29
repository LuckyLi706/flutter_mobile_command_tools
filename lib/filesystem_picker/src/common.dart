/// Enumeration with options for display types of the file system.
enum FilesystemType {
  all,
  folder,
  file,
}

/// Value selection signature.
typedef ValueSelected = void Function(String value);

/// Access permission request signature.
typedef RequestPermission = Future<bool> Function();

/// Mode for selecting files. Either only the button in the trailing
/// of ListTile, or onTap of the whole ListTile.
enum FileTileSelectMode {
  checkButton,
  wholeTile,
}
