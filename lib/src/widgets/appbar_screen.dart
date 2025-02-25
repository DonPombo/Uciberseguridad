import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class AppBarScreen extends StatelessWidget implements PreferredSizeWidget {
  const AppBarScreen({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.textColor),
          onPressed: () {
            print('Open drawer');
            Scaffold.of(context).openDrawer();
          },
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: AppTheme.textColor),
          onPressed: () {
            context.go('/profile');
          },
        ),
      ],
    );
  }
}
