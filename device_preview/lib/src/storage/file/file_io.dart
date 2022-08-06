import 'dart:convert';
import 'dart:io';

import 'package:device_preview/src/locales/default_locales.dart';
import 'package:device_preview/src/state/state.dart';
import 'package:device_preview/src/state/store.dart';
import 'package:flutter/widgets.dart';

import '../storage.dart';

/// A storage that saves device preview user preferences into
/// a single [file] as json content.
class FileDevicePreviewStorage extends DevicePreviewStorage {
  FileDevicePreviewStorage({
    required this.filePath,
  });

  /// The file to which the json content is saved to.
  final String filePath;

  /// Save the current preferences.
  @override
  Future<void> save(
    DevicePreviewData data, {
    bool overwriteIfExists = false,
  }) async {
    _saveData = data;
    _saveTask ??= _save(overwriteExisting: overwriteIfExists);
    await _saveTask;
  }

  /// Load the last saved preferences.
  @override
  Future<DevicePreviewData?> load() async {
    final json = await File(filePath).readAsString();
    if (json.isEmpty) return null;
    return DevicePreviewData.fromJson(jsonDecode(json));
  }

  Future? _saveTask;

  DevicePreviewData? _saveData;

  Future _save({
    required bool overwriteExisting,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (overwriteExisting || _saveData != null) {
      await File(filePath).writeAsString(jsonEncode(_saveData!.toJson()));
    }
    _saveTask = null;
  }

  @override

  /// Not supported on this platform.
  Future<void> clearAllDataExceptForRuntimeInspector() => Future.value();

  @override
  Future<void> resetToDefaultPreferences() async {
    final defaultLocale = basicLocaleListResolution(
      WidgetsBinding.instance.window.locales,
      defaultAvailableLocales.map((x) => x.locale).toList(),
    ).toString();
    final data = await load();
    if (data == null) return Future.value();
    await save(
      DevicePreviewData(
        locale: defaultLocale,
        customDevice: DevicePreviewStore.defaultCustomDevice,
      ),
    );
  }
}
