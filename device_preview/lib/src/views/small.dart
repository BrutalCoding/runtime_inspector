import 'dart:async';

import 'package:device_preview/src/views/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../device_preview.dart';
import 'tool_panel/tool_panel.dart';

/// The tool layout when the screen is small.
class DevicePreviewSmallLayout extends StatefulWidget {
  /// Create a new panel from the given tools grouped as [slivers].
  const DevicePreviewSmallLayout({
    Key? key,
    required this.maxMenuHeight,
    required this.scaffoldKey,
    required this.isShowingMenu,
    required this.slivers,
    this.onToggle,
  }) : super(key: key);

  /// Called whenever the toggle in the toolbar is pressed.
  final void Function(bool isOn)? onToggle;

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
  State<DevicePreviewSmallLayout> createState() =>
      _DevicePreviewSmallLayoutState();
}

class _DevicePreviewSmallLayoutState extends State<DevicePreviewSmallLayout> {
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
          onToggle: widget.onToggle,
          showPanel: () async {
            widget.isShowingMenu(true);
            final sheet = widget.scaffoldKey.currentState?.showBottomSheet(
              (context) => ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: ToolPanel(
                  title: 'Runtime Inspector',
                  isModal: true,
                  slivers: widget.slivers,
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: widget.maxMenuHeight,
              ),
              backgroundColor: Colors.transparent,
            );
            await sheet?.closed;
            widget.isShowingMenu(false);
          },
          onUserTap: () async {
            widget.isShowingMenu(true);
            final sheetWantsToClose =
                widget.scaffoldKey.currentState?.showBottomSheet(
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
                        const ListTile(
                          subtitle: Text(
                            'Tapping on any of these options will present the '
                            'app without the toolbar. '
                            'This should portray the app the same way as if '
                            'you were using the app normally as a end-user.',
                          ),
                        ),
                        ListTile(
                          title: const Text('30 seconds'),
                          subtitle: const Text(
                            'Tap to hide for 30 seconds',
                          ),
                          onTap: () {
                            final state = context.read<DevicePreviewStore>();
                            state.data = state.data.copyWith(
                              isToolbarVisible: false,
                            );
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            Future.delayed(const Duration(seconds: 30), () {
                              state.data = state.data.copyWith(
                                isToolbarVisible: true,
                              );
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('Until specific time'),
                          subtitle: const Text(
                            'Tap to hide until a specified time.',
                          ),
                          onTap: () async {
                            // Use timepicker to get the duration.
                            final timeNow = TimeOfDay.now();
                            final TimeOfDay? duration = await showTimePicker(
                              context: context,
                              initialTime: timeNow,
                              confirmText: 'Yes, hide until this time.',
                              cancelText: 'Cancel',
                            );

                            // Return if nothing has been selected.
                            if (!mounted ||
                                duration == null ||
                                timeNow == duration) return;

                            // Calculate difference in time between now and picked time
                            final diff = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              duration.hour,
                              duration.minute,
                            ).difference(DateTime.now());

                            // Continue only if the difference is positive.
                            if (diff.isNegative == false) {
                              final state = context.read<DevicePreviewStore>();

                              // Hide the menu
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                              // Hide the toolbar for the duration of the time.
                              state.data = state.data.copyWith(
                                isToolbarVisible: false,
                              );

                              Future.delayed(
                                Duration(seconds: diff.inSeconds),
                                () {
                                  state.data = state.data.copyWith(
                                    isToolbarVisible: true,
                                  );
                                },
                              );
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Permanent'),
                          subtitle: const Text(
                            'Tap to hide until re-install.',
                          ),
                          onTap: () async {
                            // Are you sure dialog
                            final bool? userHasConfirmed =
                                await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Are you sure?'),
                                content: const Text(
                                  'This will hide the toolbar permanently. The only way to show it again is to re-install the app or clearing the app cache/data on Android.',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () {
                                      final state =
                                          context.read<DevicePreviewStore>();
                                      state.data = state.data.copyWith(
                                        isToolbarVisible: false,
                                        isEnabled: false,
                                      );

                                      // Hide this dialog and menu behind.
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              ),
                            );

                            // Hide menu if user has confirmed.
                            if (userHasConfirmed == true && mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: widget.maxMenuHeight,
              ),
              backgroundColor: Colors.transparent,
            );
            await sheetWantsToClose?.closed;
            widget.isShowingMenu(false);
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
    this.onToggle,
  }) : super(key: key);

  final VoidCallback showPanel;
  final VoidCallback onUserTap;

  /// Called whenever the toggle in the toolbar is pressed.
  final void Function(bool isOn)? onToggle;

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
                onToggle?.call(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
