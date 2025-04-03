import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/widgets/custom_snackbar.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'package:uciberseguridad_app/src/services/auth_service.dart';
import 'package:uciberseguridad_app/src/models/user.dart';
import 'package:uciberseguridad_app/src/widgets/appbar_screen.dart';
import 'package:uciberseguridad_app/src/widgets/side_menu.dart';
import 'package:uciberseguridad_app/src/screens/auth/login_screen.dart';
import 'package:uciberseguridad_app/src/screens/auth/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showLogin = true;
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    _currentUser = _authService.currentUser;
    setState(() => _isLoading = false);
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      setState(() {
        _currentUser = null;
      });
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Error al cerrar sesión: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: const AppBarScreen(title: 'Perfil'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(),
              ),
            ),
    );
  }

  Widget _buildContent() {
    if (_currentUser != null) {
      return Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProgressSection(),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
        ],
      );
    } else {
      return _showLogin
          ? LoginScreen(
              onShowRegister: () => setState(() => _showLogin = false),
              onLoginSuccess: (user) {
                setState(() => _currentUser = user);
              },
            )
          : RegisterScreen(
              onShowLogin: () => setState(() => _showLogin = true),
              onRegisterSuccess: (user) {
                setState(() => _currentUser = user);
              },
            );
    }
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.accentColor,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser?.name ?? 'Usuario',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso General',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              'Fundamentos de Ciberseguridad',
              0.7,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              'Seguridad en Redes',
              0.4,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              'Ethical Hacking',
              0.2,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% Completado',
          style: TextStyle(
            color: AppTheme.textColor.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Cuestionarios\nCompletados',
            '12',
            Icons.quiz,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Puntuación\nPromedio',
            '85%',
            Icons.star,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            'Editar Perfil',
            Icons.edit,
            () {
              // TODO: Implementar edición de perfil
            },
          ),
          const Divider(),
          _buildSettingsItem(
            'Notificaciones',
            Icons.notifications,
            () {
              // TODO: Implementar configuración de notificaciones
            },
          ),
          const Divider(),
          _buildSettingsItem(
            'Cerrar Sesión',
            Icons.logout,
            _handleSignOut,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppTheme.accentColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppTheme.textColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
