import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/widgets/appbar_screen.dart';
import 'package:uciberseguridad_app/src/widgets/side_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return const Scaffold(
        drawer: SideMenu(),
        appBar: AppBarScreen(title: 'Profile'),
        body: Center(
          child: Text('Profile'),
        ),
      );
    });
  }
}
