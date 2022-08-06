import 'dart:convert';

import 'package:device_preview/src/locales/default_locales.dart';
import 'package:device_preview/src/state/state.dart';
import 'package:device_preview/src/state/store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage.dart';

/// A storage that keeps all preferences stored as json in the
/// preference entry with the [preferenceKey] key.
class PreferencesDevicePreviewStorage extends DevicePreviewStorage {
  PreferencesDevicePreviewStorage({
    this.preferenceKey = defaultPreferencesKey,
  });

  /// The preferences key used to save the user configuration.
  final String preferenceKey;

  /// The default preferences key used to save the user configuration.
  static const String defaultPreferencesKey = 'device_preview.settings';

  /// Load the last saved preferences (until [ignore] is `true`).
  @override
  Future<DevicePreviewData?> load() async {
    final shared = await SharedPreferences.getInstance();
    final json = shared.getString(preferenceKey);
    if (json == null || json.isEmpty) return null;
    return DevicePreviewData.fromJson(jsonDecode(json));
  }

  /// Save the current preferences (until [ignore] is `true`).
  @override
  Future<void> save(
    DevicePreviewData data, {
    required bool overwriteIfExists,
  }) async {
    _saveData = data;
    _saveTask ??= _save(overwriteExisting: overwriteIfExists);
    await _saveTask;
  }

  Future<void>? _saveTask;
  DevicePreviewData? _saveData;

  Future _save({required bool overwriteExisting}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (overwriteExisting || _saveData != null) {
      final shared = await SharedPreferences.getInstance();
      await shared.setString(preferenceKey, jsonEncode(_saveData!.toJson()));
    }
    _saveTask = null;
  }

  @override
  Future<void> clearAllDataExceptForRuntimeInspector() async {
    // Load preferences and store this in memory..
    final data = await load();

    // Delete all data from app support directory
    try {
      final applicationSupportDirectory =
          await getApplicationSupportDirectory();
      if (applicationSupportDirectory.existsSync()) {
        await applicationSupportDirectory.delete(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Could not delete applicationSupportDirectory for some reason.\n$e',
        );
      }
    }

    // Delete all data from temporary directory
    try {
      final temporaryDirectory = await getTemporaryDirectory();
      if (temporaryDirectory.existsSync()) {
        await temporaryDirectory.delete(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Could not delete temporaryDirectory for some reason.\n$e',
        );
      }
    }

    try {
      final sp = await SharedPreferences.getInstance();
      await sp.clear();
    } catch (e) {
      if (kDebugMode) {
        print(
          'Could not delete SharedPreferences for some reason.\n$e',
        );
      }
    }

    // Save data from memory to disk
    if (data != null) {
      await save(data, overwriteIfExists: true);
    }
  }

  @override
  Future<void> resetToDefaultPreferences() async {
    final defaultLocale = basicLocaleListResolution(
      WidgetsBinding.instance.window.locales,
      defaultAvailableLocales.map((x) => x.locale).toList(),
    ).toString();
    await save(
      DevicePreviewData(
        locale: defaultLocale,
        customDevice: DevicePreviewStore.defaultCustomDevice,
      ),
      overwriteIfExists: true,
    );
  }
}
