import 'package:flutter/material.dart';
///
/// Widget of control buttons for working with the device.
class DeviceButtons extends StatelessWidget {
  final bool showAdditionalButtons;
  final VoidCallback onPlusPressed;
  final VoidCallback onInfoPressed;
  final VoidCallback onDocPressed;
  final double defaultPadding;
  ///
  /// Creates a new instanse of [DeviceButtons] with [key], visibility flag [showAdditionalButtons],
  /// callback of pressing the main button [onPlusPressed], callback of pressing info button [onInfoPressed]
  /// and callback of pressing doc button [onDocPressed].
  const DeviceButtons({
    super.key,
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
          children: [
            if (showAdditionalButtons) ...[
              _buildButton(
                  context: context, icon: Icons.info, onPressed: onInfoPressed),
              _buildButton(
                  context: context,
                  icon: Icons.document_scanner,
                  onPressed: onDocPressed),
            ],
            _buildButton(
                context: context,
                icon: Icons.add_circle,
                onPressed: onPlusPressed),
          ],
        ));
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
