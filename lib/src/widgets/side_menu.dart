import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.accentColor,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Usuario',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Progreso: 55%',
            style: TextStyle(
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
        ],
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