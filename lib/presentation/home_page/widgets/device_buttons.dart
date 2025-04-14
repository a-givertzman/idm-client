import 'package:flutter/material.dart';

///
/// Widget of control buttons for working with the device.
class DeviceButtons extends StatelessWidget {
  final bool showAdditionalButtons;
  final VoidCallback onPlusPressed;
  final VoidCallback onInfoPressed;
  final VoidCallback onDocPressed;

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
  });
  //
  //
  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: 24,
        bottom: 48, // another padding
        child: Column(
          children: [
            if (showAdditionalButtons) ...[
              ElevatedButton(
                onPressed: onInfoPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 102, 163, 210)),
                child: const Icon(
                  Icons.info,
                  color: Color.fromARGB(255, 3, 62, 107),
                ),
              ),
              ElevatedButton(
                onPressed: onDocPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 102, 163, 210)),
                child: const Icon(
                  Icons.document_scanner,
                  color: Color.fromARGB(255, 3, 62, 107),
                ),
              )
            ],
            ElevatedButton(
              onPressed: onPlusPressed,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 102, 163, 210)),
              child: const Icon(
                Icons.add_circle,
                color: Color.fromARGB(255, 3, 62, 107),
              ),
            ),
          ],
        ));
  }
}
