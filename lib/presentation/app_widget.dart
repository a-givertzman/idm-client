import 'package:flutter/material.dart';
import 'package:idm_client/infrostructure/custom_theme.dart';
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
      theme: customTheme,
      home: const HomePage(),
    );
  }
}
