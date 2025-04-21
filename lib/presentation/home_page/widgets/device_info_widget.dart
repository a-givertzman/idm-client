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
  final double defaultPadding;
  ///
  /// Creates a new instanse of [DeviceInfoWidget] with [key], given id of device [devId],
  /// callback of pressing close button [onClosePressed] and current address [apiAddress]
  const DeviceInfoWidget({
    super.key,
    required this.devId,
    required this.onClosePressed,
    this.apiAddress = '',
    this.defaultPadding = 24,
  });
  @override
  State<DeviceInfoWidget> createState() => _DeviceInfoWidgetState();
}
///
/// Status of the [DeviceInfoWidget].
class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  final _log = const Log("DeviceInfoWidget");
  //
  //
  @override
  void initState() {
    super.initState();
  }
  //
  //
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
            left: widget.defaultPadding,
            top: widget.defaultPadding * 4,
            right: widget.defaultPadding,
            bottom: widget.defaultPadding * 6),
        child: FutureBuilder<Result<DeviceInfo, Failure>>(
          future: DeviceInfo.fromApi(address: widget.apiAddress)
              .fetch(widget.devId),
          builder: (BuildContext context,
              AsyncSnapshot<Result<DeviceInfo, Failure>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
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
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(error,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer)),
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
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: ${widget.devId}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('manufacturer: ${info.manufacturer}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('name: ${info.name}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('model: ${info.model}',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('description: ${info.description}',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
      Positioned(
          top: widget.defaultPadding / 4,
          right: widget.defaultPadding / 4,
          child: IconButton(
              color: Theme.of(context).colorScheme.onSecondary,
              onPressed: widget.onClosePressed,
              icon: const Icon(Icons.close)))
    ]);
  }
}
