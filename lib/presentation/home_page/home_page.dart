import 'package:flutter/material.dart';
import 'package:idm_client/presentation/home_page/widgets/home_body.dart';

///
/// HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;
  //
  //
  @override
  Widget build(BuildContext context) {
    return const HomeBody();
  }
}
