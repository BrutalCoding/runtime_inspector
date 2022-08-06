import 'dart:developer';

import 'package:device_preview/src/state/state.dart';

import '../storage.dart';

/// This storage isn't supported when targeting web platform.
///
/// The preferences won't be persisted between session when using this storage.
class FileDevicePreviewStorage extends DevicePreviewStorage {
  FileDevicePreviewStorage({
    required this.filePath,
  });

  /// The file to which the json content is saved to.
  final String filePath;

  void showErrorInConsole() {
    log('WARNING: FileDevicePreviewStorage isn\'t supported on web. The settings won\'t be persisted.');
  }

  @override
  Future<DevicePreviewData?> load() {
    showErrorInConsole();
    return Future<DevicePreviewData?>.value(null);
  }

  @override
  Future<void> save(
    DevicePreviewData data, {
    bool overwriteIfExists = false,
  }) {
    showErrorInConsole();
    return Future.value();
  }

  @override
  Future<void> clearAllDataExceptForRuntimeInspector() {
    showErrorInConsole();
    return Future.value();
  }

  @override
  Future<void> resetToDefaultPreferences() {
    showErrorInConsole();
    return Future.value();
  }
}
