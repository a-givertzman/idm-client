import 'package:flutter/material.dart';
import 'package:idm_client/presentation/home_page/home_page.dart';
///
/// Application widget.
class AppWidget extends StatelessWidget {
  const AppWidget({super.key});
  //
  //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}
