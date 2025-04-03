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
        right: 20,
        bottom: 60, // another padding
        child: Column(
          children: [
            if(showAdditionalButtons)...[
                ElevatedButton(
                  onPressed: onInfoPressed, 
                  child: Icon(
                    Icons.info,
                    color: Color.fromARGB(255, 3, 62, 107),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 102, 163, 210)
                  ),
                  ),
                ElevatedButton(
                  onPressed: onDocPressed, 
                  child: Icon(
                    Icons.document_scanner, 
                    color: Color.fromARGB(255, 3, 62, 107),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 102, 163, 210)
                  ),
                )
              ],
            ElevatedButton(
              onPressed: onPlusPressed, 
              child: Icon(Icons.add_circle, color: Color.fromARGB(255, 3, 62, 107),),
              style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 102, 163, 210)
              ),
            ),
            ],
        ));
    //                     if (_showInfo) ...[loadInfo()],
    //                     if (_showDoc) ...[loadDoc()],
  }
}
