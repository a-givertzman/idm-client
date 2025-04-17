import 'package:flutter/material.dart';
import 'package:hmi_core/hmi_core_log.dart';
import 'package:hmi_core/hmi_core_result.dart';
import 'package:idm_client/domain/error/failure.dart';
import 'package:idm_client/infrostructure/device_info/device_info.dart';

///
/// Widget for showing information frame
class DeviceInfoWidget extends StatefulWidget {
  final String devId;
  final VoidCallback onClosePressed;
  final String apiAddress;
  ///
  /// Creates a new instanse of [DeviceInfoWidget] with [key], given id of device [devId],
  /// callback of pressing close button [onClosePressed] and current address [apiAddress]
  const DeviceInfoWidget({
    super.key,
    required this.devId,
    required this.onClosePressed,
    this.apiAddress = '',
  });

  @override
  State<DeviceInfoWidget> createState() => _DeviceInfoWidgetState();
}
//
//
class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  final _log = const Log("DeviceInfoWidget");
  //
  //
  @override
  Widget build(BuildContext context) {
    const customPadding = 24.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
            left: customPadding,
            top: customPadding * 4,
            right: customPadding,
            bottom: customPadding * 6),
        child: FutureBuilder<Result<DeviceInfo, Failure>>(
          future: DeviceInfo.fromApi(address: widget.apiAddress)
              .fetch(widget.devId),
          builder: (BuildContext context,
              AsyncSnapshot<Result<DeviceInfo, Failure>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 102, 163, 210),
                ),
              );
            }
            switch (snapshot.data) {
              case Ok(value: final devInfo):
                _log.trace('.build | devInfo: $devInfo');
                return _buildInfo(devInfo);
              case Err(error: final error):
                _log.warn('.build | error: $error');
                return _buildError('error');
              case null:
                if (snapshot.hasError) {
                  _log.warn('.build | error: ${snapshot.error}');
                  return _buildError('${snapshot.error}');
                }
                return _buildError(
                    'No info found for divice ID "${widget.devId}"');
            }
          },
        ),
      ),
    );
  }
  ///
  /// Building an error frame.
  Widget _buildError(String error) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 34, 36, 37),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(error, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
  ///
  /// Building an inforamation frame.
  Widget _buildInfo(DeviceInfo info) {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 37, 86, 123),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: ${widget.devId}',
                style: const TextStyle(color: Colors.white)),
            Text('manufacturer: ${info.manufacturer}',
                style: const TextStyle(color: Colors.white)),
            Text('name: ${info.name}',
                style: const TextStyle(color: Colors.white)),
            Text('model: ${info.model}',
                style: const TextStyle(color: Colors.white)),
            Text('description: ${info.description}',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      Positioned(
          top: 6,
          right: 6,
          child: IconButton(
              color: Colors.white,
              onPressed: widget.onClosePressed,
              icon: const Icon(Icons.close)))
    ]);
  }
}
