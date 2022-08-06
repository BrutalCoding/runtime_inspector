import 'package:device_preview/src/views/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../device_preview.dart';
import 'tool_panel/tool_panel.dart';

/// The tool layout when the screen is small.
class DevicePreviewSmallLayout extends StatelessWidget {
  /// Create a new panel from the given tools grouped as [slivers].
  const DevicePreviewSmallLayout({
    Key? key,
    required this.maxMenuHeight,
    required this.scaffoldKey,
    required this.isShowingMenu,
    required this.slivers,
  }) : super(key: key);

  /// The maximum modal menu height.
  final double maxMenuHeight;

  /// The key of the [Scaffold] that must be used to show the modal menu.
  final GlobalKey<ScaffoldState> scaffoldKey;

  /// Invoked each time the menu is shown or hidden.
  final ValueChanged<bool> isShowingMenu;

  /// The sections containing the tools.
  ///
  /// They must be [Sliver]s.
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final toolbarTheme = context.select(
      (DevicePreviewStore store) => store.settings.toolbarTheme,
    );
    return Theme(
      data: toolbarTheme.asThemeData(),
      child: SafeArea(
        top: false,
        child: _BottomToolbar(
          showPanel: () async {
            isShowingMenu(true);
            final sheet = scaffoldKey.currentState?.showBottomSheet(
              (context) => ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: ToolPanel(
                  title: 'Runtime Inspector',
                  isModal: true,
                  slivers: slivers,
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: maxMenuHeight,
              ),
              backgroundColor: Colors.transparent,
            );
            await sheet?.closed;
            isShowingMenu(false);
          },
          onUserTap: () async {
            isShowingMenu(true);
            final sheetWantsToClose = scaffoldKey.currentState?.showBottomSheet(
              (context) => ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: ToolPanel(
                  title: 'End User Experience',
                  isModal: true,
                  slivers: [
                    ToolPanelSection(
                      title: 'Experience app like your end-user',
                      children: [
                        // ListTile(
                        //   title: const Text('Hide for 10 seconds'),
                        //   subtitle: const Text(
                        //     'Tap to view the app like an end user for 10 seconds.',
                        //   ),
                        //   onTap: () {
                        //     if (Navigator.canPop(context)) {
                        //       final state = context.read<DevicePreviewStore>();
                        //       state.data = state.data.copyWith(
                        //         isToolbarVisible: false,
                        //         isEnabled: false,
                        //       );
                        //       Navigator.pop(context);
                        //       isDisplayingRuntimeInspectorPanel(false);
                        //       Future.delayed(
                        //         const Duration(seconds: 10),
                        //         () {
                        //           DevicePreview.resetToDefaultSettings();
                        //         },
                        //       );
                        //     }
                        //   },
                        // ),
                        ListTile(
                          title: const Text('Permanently'),
                          subtitle: const Text(
                            'Requires app to be re-installed to undo.',
                          ),
                          onTap: () {
                            final state = context.read<DevicePreviewStore>();
                            state.data = state.data.copyWith(
                              isToolbarVisible: false,
                              isEnabled: false,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                        // const ListTile(
                        //   title: Text('Hide until tapped'),
                        //   subtitle: Text(
                        //     'Tap anywhere on the screen to undo.',
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: maxMenuHeight,
              ),
              backgroundColor: Colors.transparent,
            );
            await sheetWantsToClose?.closed;
            isShowingMenu(false);
          },
        ),
      ),
    );
  }
}

class _BottomToolbar extends StatelessWidget {
  const _BottomToolbar({
    Key? key,
    required this.showPanel,
    required this.onUserTap,
  }) : super(key: key);

  final VoidCallback showPanel;
  final VoidCallback onUserTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = context.select(
      (DevicePreviewStore store) => store.data.isEnabled,
    );
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: isEnabled ? showPanel : null,
                icon: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isEnabled ? 1 : 0.5,
                  child: const Icon(
                    Icons.tune,
                  ),
                ),
              ),
              IconButton(
                onPressed: !isEnabled ? onUserTap : null,
                icon: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: !isEnabled ? 1 : 0.5,
                  child: const Icon(
                    Icons.person,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Runtime Inspector is ${isEnabled ? 'enabled' : 'disabled'}.',
                ),
                Text(
                  'End User Experience ${isEnabled ? 'disabled' : 'available'}.',
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Switch(
              value: isEnabled,
              onChanged: (v) {
                final state = context.read<DevicePreviewStore>();
                state.data = state.data.copyWith(isEnabled: v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
