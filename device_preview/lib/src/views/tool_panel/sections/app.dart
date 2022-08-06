import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// All the settings for customizing the preview.
class AppSection extends StatelessWidget {
  /// Create a new menu section with settings for customizing the preview.
  ///
  /// The items can be hidden with [backgroundTheme], [toolsTheme] parameters.
  const AppSection({
    Key? key,
    this.backgroundTheme = true,
    this.toolsTheme = true,
  }) : super(key: key);

  /// Allow to edit the current background theme.
  final bool backgroundTheme;

  /// Allow to edit the current toolbar theme.
  final bool toolsTheme;

  @override
  Widget build(BuildContext context) {
    return ToolPanelSection(
      title: 'App settings',
      children: [
        ListTile(
          title: const Text('Delete app data'),
          subtitle: const Text(
            'Clears all the cached data stored in your app and force refreshes the UI. Long tap to skip force refresh.',
          ),
          onLongPress: () async {
            final provider = context.read<DevicePreviewStore>();
            await provider.storage.clearAllDataExceptForRuntimeInspector();
          },
          onTap: () async {
            final provider = context.read<DevicePreviewStore>();
            await provider.storage.clearAllDataExceptForRuntimeInspector();
            provider.data = provider.data.copyWith(forceRefreshUI: true);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                provider.data = provider.data.copyWith(forceRefreshUI: false);
              },
            );
          },
        ),
        ListTile(
          title: const Text('Force refresh UI'),
          subtitle: const Text(
            'Forces a rebuild of the widget tree.',
          ),
          onTap: () async {
            final provider = context.read<DevicePreviewStore>();
            provider.data = provider.data.copyWith(forceRefreshUI: true);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                provider.data = provider.data.copyWith(forceRefreshUI: false);
              },
            );
          },
        ),
      ],
    );
  }
}
