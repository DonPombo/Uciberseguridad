import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uciberseguridad_app/src/blocs/blocs.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final titleWidth = title.length * 12.0;
        const buttonWidth = 80.0;

        if (availableWidth >= titleWidth + buttonWidth + 20) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NavigationBloc>().add(const NavigationIndexChanged(1));
                  context.go('/lessons');
                },
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  context.read<NavigationBloc>().add(const NavigationIndexChanged(1));
                  context.go('/lessons');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}