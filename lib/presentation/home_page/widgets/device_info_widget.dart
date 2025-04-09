import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hmi_core/hmi_core_log.dart';

class DeviceInfoWidget extends StatefulWidget {
  final String devId;

  const DeviceInfoWidget({
    super.key,
    required this.devId,
  });

  @override
  State<DeviceInfoWidget> createState() => _DeviceInfoWidgetState();
}

class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  late Future<Map<String, dynamic>> _deviceInfoFuture;
  final _log = const Log("DeviceInfoWidget");

  @override
  void initState() {
    super.initState();
    _deviceInfoFuture = _fetchDeviceInfo(widget.devId);
  }

  Future<Map<String, dynamic>> _fetchDeviceInfo(String devId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final content = await rootBundle.loadString('assets/device/device.json');
      final devices = jsonDecode(content);

      Map<String, dynamic> response;
      if (devices.containsKey(devId)) {
        response = {
          "ok": devices[devId],
          "err": null,
        };
      } else {
        response = {
          "ok": null,
          "err": {
            "msg": "Device not found",
            "details": "No data for dev-id '$devId'"
          },
        };
      }

      if (response['ok'] != null) {
        return devices[devId];
      } else {
        throw Exception('Устройство не найдено');
      }
    } catch (e) {
      _log.warn('Error loading device info: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    const padding = 24.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            padding, padding * 4, padding, padding * 6),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _deviceInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 102, 163, 210),
                ),
              );
            }
            if (snapshot.hasError && snapshot.data == null) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 34, 36, 37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No data available for this device!',
                      style: TextStyle(color: Colors.white)),
                ),
              );
            }

            final info = snapshot.data!;
            return Container(
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
                  Text('manufacturer: ${info['manufacturer']}',
                      style: const TextStyle(color: Colors.white)),
                  Text('name: ${info['name']}',
                      style: const TextStyle(color: Colors.white)),
                  Text('model: ${info['model']}',
                      style: const TextStyle(color: Colors.white)),
                  Text('description: ${info['description']}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
