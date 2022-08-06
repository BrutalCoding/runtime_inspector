// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:html' as html;

import 'package:device_preview/src/locales/default_locales.dart';
import 'package:device_preview/src/state/state.dart';
import 'package:device_preview/src/state/store.dart';
import 'package:flutter/widgets.dart';
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
    final json = html.window.localStorage['flutter.$defaultPreferencesKey'];
    if (json == null || json.isEmpty) return null;
    return DevicePreviewData.fromJson(jsonDecode(json));
  }

  /// Save the current preferences (until [ignore] is `true`).
  @override
  Future<void> save(
    DevicePreviewData data, {
    bool overwriteIfExists = false,
  }) async {
    _saveData = data;
    _saveTask ??= _save();
    await _saveTask;
  }

  Future<void>? _saveTask;
  DevicePreviewData? _saveData;

  Future _save({bool overwriteExisting = false}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (overwriteExisting || _saveData != null) {
      html.window.localStorage['flutter.$defaultPreferencesKey'] =
          jsonEncode(_saveData!.toJson());
    }
    _saveTask = null;
  }

  @override
  Future<void> clearAllDataExceptForRuntimeInspector() async {
    // Load preferences and store this in memory..
    final data = await load();

    // Delete all data from app support directory
    html.window.localStorage.clear();

    // Delete all data from SharedPreferences
    final sp = await SharedPreferences.getInstance();
    await sp.clear();

    // Save data from memory to disk
    if (data != null) {
      await save(data);
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
    );
  }
}
