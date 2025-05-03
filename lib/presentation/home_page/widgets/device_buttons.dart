import 'package:flutter/material.dart';
import 'package:idm_client/domain/device.dart';
///
/// Widget of control buttons for working with the device.
class DeviceButtons extends StatelessWidget {
  final Map<String, Device> devices;
  final bool showAdditionalButtons;
  final VoidCallback onPlusPressed;
  final void Function(String devId) onInfoPressed;
  final void Function(String devId) onDocPressed;
  final double defaultPadding;
  ///
  /// Creates a new instanse of [DeviceButtons] with [key], visibility flag [showAdditionalButtons],
  /// callback of pressing the main button [onPlusPressed], callback of pressing info button [onInfoPressed]
  /// and callback of pressing doc button [onDocPressed].
  const DeviceButtons({
    super.key,
    required this.devices,
    required this.showAdditionalButtons,
    required this.onPlusPressed,
    required this.onInfoPressed,
    required this.onDocPressed,
    this.defaultPadding = 24,
  });
  //
  //
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: defaultPadding,
      bottom: defaultPadding * 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAdditionalButtons)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: devices.values.map((device) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(
                              device.id,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          SizedBox(width: defaultPadding / 4),
                          _buildButton(
                            context: context,
                            icon: Icons.info,
                            onPressed: () => onInfoPressed(device.id),
                          ),
                          SizedBox(width: defaultPadding / 4),
                          _buildButton(
                            context: context,
                            icon: Icons.document_scanner,
                            onPressed: () => onDocPressed(device.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          _buildButton(
              context: context,
              icon: showAdditionalButtons
                  ? Icons.remove_circle
                  : Icons.add_circle,
              onPressed: onPlusPressed),
        ],
      ),
    );
  }
  //
  //
  Widget _buildButton(
      {required BuildContext context,
      required IconData icon,
      required VoidCallback onPressed}) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ));
  }
}
