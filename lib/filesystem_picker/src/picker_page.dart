import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'common.dart';
import 'filesystem_list.dart';
import 'package:path/path.dart' as Path;
import 'breadcrumbs.dart';

class _PathItem {
  final String text;
  final String path;

  _PathItem({
    required this.path,
    required this.text,
  });

  @override
  String toString() {
    return '$text: $path';
  }
}

/// FileSystem file or folder picker dialog.
///
/// Allows the user to browse the file system and pick a folder or file.
///
/// See also:
///
///  * [FilesystemPicker.open]
class FilesystemPicker extends StatefulWidget {
  /// Open FileSystemPicker dialog
  ///
  /// Returns null if nothing was selected.
  ///
  /// * [rootDirectory] specifies the root of the filesystem view.
  /// * [rootName] specifies the name of the filesystem view root in breadcrumbs, by default "Storage".
  /// * [fsType] specifies the type of filesystem view (folder and files, folder only or files only), by default `FilesystemType.all`.
  /// * [pickText] specifies the text for the folder selection button (only for [fsType] = FilesystemType.folder).
  /// * [permissionText] specifies the text of the message that there is no permission to access the storage, by default: "Access to the storage was not granted.".
  /// * [title] specifies the text of the dialog title.
  /// * [allowedExtensions] specifies a list of file extensions that will be displayed for selection, if empty - files with any extension are displayed. Example: `['.jpg', '.jpeg']`
  /// * [fileTileSelectMode] specifies how to files can be selected (either tapping on the whole tile or only on trailing button). (default depends on [fsType])
  /// * [requestPermission] if specified will be called on initialization to request storage permission. callers can use e.g. [permission_handler](https://pub.dev/packages/permission_handler).
  static Future<String?> open({
    required BuildContext context,
    required Directory rootDirectory,
    String rootName = 'Storage',
    FilesystemType fsType = FilesystemType.all,
    String? pickText,
    String? permissionText,
    String? title,
    Color? folderIconColor,
    List<String>? allowedExtensions,
    FileTileSelectMode fileTileSelectMode = FileTileSelectMode.checkButton,
    RequestPermission? requestPermission,
  }) async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (BuildContext context) {
        return FilesystemPicker(
          rootDirectory: rootDirectory,
          rootName: rootName,
          fsType: fsType,
          pickText: pickText,
          permissionText: permissionText,
          title: title,
          folderIconColor: folderIconColor,
          allowedExtensions: allowedExtensions,
          onSelect: (String value) {
            Navigator.of(context).pop<String>(value);
          },
          fileTileSelectMode: fileTileSelectMode,
          requestPermission: requestPermission,
        );
      }),
    );
  }

  // ---

  /// Specifies the name of the filesystem view root in breadcrumbs.
  final String? rootName;

  /// Specifies the root of the filesystem view.
  final Directory rootDirectory;

  /// Specifies the type of filesystem view (folder and files, folder only or files only), by default `FilesystemType.all`.
  final FilesystemType fsType;

  /// Called when a file system item is selected.
  final ValueSelected onSelect;

  /// Specifies the text for the folder selection button (only for [fsType] = FilesystemType.folder).
  final String? pickText;

  /// Specifies the text of the message that there is no permission to access the storage, by default: "Access to the storage was not granted.".
  final String? permissionText;

  /// Specifies the text of the dialog title.
  final String? title;

  /// Specifies the color of the icon for the folder.
  final Color? folderIconColor;

  /// Specifies a list of file extensions that will be displayed for selection, if empty - files with any extension are displayed. Example: `['.jpg', '.jpeg']`
  final List<String>? allowedExtensions;

  /// Specifies how to files can be selected (either tapping on the whole tile or only on trailing button). (default depends on [fsType])
  final FileTileSelectMode fileTileSelectMode;

  /// If specified will be called on initialization to request storage permission. callers can use e.g. [permission_handler](https://pub.dev/packages/permission_handler).
  final RequestPermission? requestPermission;

  /// Creates a file system item selection widget.
  FilesystemPicker({
    Key? key,
    this.rootName,
    required this.rootDirectory,
    this.fsType = FilesystemType.all,
    this.pickText,
    this.permissionText,
    this.title,
    this.folderIconColor,
    this.allowedExtensions,
    required this.onSelect,
    required this.fileTileSelectMode,
    this.requestPermission,
  }) : super(key: key);

  @override
  _FilesystemPickerState createState() => _FilesystemPickerState();
}

class _FilesystemPickerState extends State<FilesystemPicker> {
  bool permissionRequesting = true;
  bool permissionAllowed = false;

  late Directory directory;
  String? directoryName;
  late List<_PathItem> pathItems;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _setDirectory(widget.rootDirectory);
  }

  Future<void> _requestPermission() async {
    final requestPermission = widget.requestPermission;
    if (requestPermission == null || await requestPermission()) {
      permissionAllowed = true;
    }

    permissionRequesting = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _setDirectory(Directory value) {
    directory = value;

    String dirPath = Path.relative(directory.path,
        from: Path.dirname(widget.rootDirectory.path));
    final List<String> items = dirPath.split(Platform.pathSeparator);
    pathItems = [];

    String rootItem = items.first;
    String rootPath = Path.dirname(widget.rootDirectory.path) +
        Platform.pathSeparator +
        rootItem;
    pathItems.add(_PathItem(path: rootPath, text: widget.rootName ?? rootItem));
    items.removeAt(0);

    String path = rootPath;

    for (var item in items) {
      path += Platform.pathSeparator + item;
      pathItems.add(_PathItem(path: path, text: item));
    }

    directoryName = ((directory.path == widget.rootDirectory.path) &&
            (widget.rootName != null))
        ? widget.rootName
        : Path.basename(directory.path);
  }

  void _changeDirectory(Directory value) {
    if (directory != value) {
      setState(() {
        _setDirectory(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? directoryName!),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          child: Theme(
            data: ThemeData(
              textTheme: TextTheme(
                button: TextStyle(
                    color: AppBarTheme.of(context)
                            .textTheme
                            ?.headline6
                            ?.color ??
                        Theme.of(context).primaryTextTheme.headline6?.color),
              ),
            ),
            child: Breadcrumbs<String>(
              items: (!permissionRequesting && permissionAllowed)
                  ? pathItems
                      .map((path) => BreadcrumbItem<String>(
                          text: path.text, data: path.path))
                      .toList(growable: false)
                  : [],
              onSelect: (String? value) {
                if (value != null) _changeDirectory(Directory(value));
              },
            ),
          ),
          preferredSize: const Size.fromHeight(50),
        ),
      ),
      body: permissionRequesting
          ? Center(child: CircularProgressIndicator())
          : (permissionAllowed
              ? FilesystemList(
                  isRoot: (directory.absolute.path ==
                      widget.rootDirectory.absolute.path),
                  rootDirectory: directory,
                  fsType: widget.fsType,
                  folderIconColor: widget.folderIconColor,
                  allowedExtensions: widget.allowedExtensions,
                  onChange: _changeDirectory,
                  onSelect: widget.onSelect,
                  fileTileSelectMode: widget.fileTileSelectMode,
                )
              : Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                      widget.permissionText ??
                          'Access to the storage was not granted.',
                      textScaleFactor: 1.2),
                )),
      bottomNavigationBar: (widget.fsType == FilesystemType.folder)
          ? Container(
              height: 50,
              child: BottomAppBar(
                color: Theme.of(context).primaryColor,
                child: Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      primary: AppBarTheme.of(context)
                              .textTheme
                              ?.headline6
                              ?.color ??
                          Theme.of(context).primaryTextTheme.headline6?.color,
                      onSurface: (AppBarTheme.of(context)
                                  .textTheme
                                  ?.headline6
                                  ?.color ??
                              Theme.of(context)
                                  .primaryTextTheme
                                  .headline6
                                  ?.color)!
                          .withOpacity(0.5),
                    ),
                    icon: Icon(Icons.check_circle),
                    label: (widget.pickText != null)
                        ? Text(widget.pickText!)
                        : const SizedBox(),
                    onPressed: (!permissionRequesting && permissionAllowed)
                        ? () => widget.onSelect(directory.absolute.path)
                        : null,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
