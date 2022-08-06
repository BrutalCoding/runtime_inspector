import 'package:device_preview/src/state/state.dart';

import 'preferences/preferences.dart';

/// A storage for device preview user's preferences.
abstract class DevicePreviewStorage {
  const DevicePreviewStorage();

  /// A storage that keep preferences only in memory : all preferences are reset on each
  /// fresh start of the app.
  factory DevicePreviewStorage.none() => const NoDevicePreviewStorage();

  /// A storage that keeps all preferences stored as json in the
  /// preferences entry with the [preferenceKey] key.
  factory DevicePreviewStorage.preferences({
    String preferenceKey =
        PreferencesDevicePreviewStorage.defaultPreferencesKey,
  }) =>
      PreferencesDevicePreviewStorage(
        preferenceKey: preferenceKey,
      );

  /// Save the given [data] to the storage so that it can be loaded
  /// later with the [load] method.
  /// When [overwriteIfExists] is `true`, any existing data will be overwritten.
  Future<void> save(DevicePreviewData data, {required bool overwriteIfExists});

  /// Load data from the storage that has been saved previously with
  /// the [save] method.
  Future<DevicePreviewData?> load();

  /// Clears all [SharedPreferences] data except the Runtime Inspector preferences.
  /// If your app is using other ways to store preferences, this will not work.
  Future<void> clearAllDataExceptForRuntimeInspector();

  /// Resets to the default preferences.
  Future<void> resetToDefaultPreferences();
}

/// A storage that keep preferences only in memory : they are reset on each
/// fresh start of the app.
class NoDevicePreviewStorage extends DevicePreviewStorage {
  const NoDevicePreviewStorage();

  @override
  Future<DevicePreviewData?> load() => Future<DevicePreviewData?>.value(null);

  @override
  Future<void> save(DevicePreviewData data, {bool overwriteIfExists = false}) =>
      Future.value();

  @override
  Future<void> clearAllDataExceptForRuntimeInspector() => Future.value();

  @override
  Future<void> resetToDefaultPreferences() => Future.value();
}
