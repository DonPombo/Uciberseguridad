import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/src/blocs/blocs.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class BottomNavegationBar extends StatelessWidget {
  const BottomNavegationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: AppTheme.backgroundColor,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: AppTheme.textColor,
          currentIndex: state.currentIndex,
          onTap: (index) {
            context.read<NavigationBloc>().add(NavigationIndexChanged(index));

            _navigateToPage(context, index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.home_outlined),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              activeIcon: Icon(Icons.book_outlined),
              label: 'Lecciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer),
              activeIcon: Icon(Icons.question_answer_outlined),
              label: 'Cuestionarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: Icon(Icons.person_2_outlined),
              label: 'Perfil',
            ),
          ],
        );
      },
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    final routes = [
      '/',
      '/lessons',
      '/quiz',
      '/profile',
    ];
    if (index < routes.length) {
      context.go(routes[index]);
    }
  }
}
