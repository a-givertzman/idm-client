import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:idm_client/main.dart';
///
/// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  //
  //
  @override
  State<HomePage> createState() => _MyHomePageState();
}
//
//
class _MyHomePageState extends State<HomePage> {
  late CameraController _controller;
  //
  //
  @override
  void initState() {
    initCamera();
    super.initState();
  }
  //
  //
  initCamera() {
    _controller = CameraController(cameras[0], ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }
  //
  //
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //
  //
  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    } else {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.transparent,
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
