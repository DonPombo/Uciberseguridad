import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'package:uciberseguridad_app/src/services/auth_service.dart';
import 'package:uciberseguridad_app/src/models/user.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          FutureBuilder<String?>(
            future: authService.getCurrentUserRole(),
            builder: (context, snapshot) {
              return _buildHeader(currentUser, snapshot.data);
            },
          ),
          const Divider(),
          _buildMenuItem(
            context,
            'Inicio',
            Icons.home_outlined,
            '/',
          ),
          _buildMenuItem(
            context,
            'Lecciones',
            Icons.book_outlined,
            '/lessons',
          ),
          _buildMenuItem(
            context,
            'Cuestionarios',
            Icons.question_answer_outlined,
            '/quiz',
          ),
          _buildMenuItem(
            context,
            'Perfil',
            Icons.person_2_outlined,
            '/profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User? currentUser, String? userRole) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.accentColor,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentUser?.name ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userRole == 'admin') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        color: AppTheme.quaternaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              currentUser?.email ?? '',
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Cierra el drawer
        context.go(route);
      },
    );
  }
}
