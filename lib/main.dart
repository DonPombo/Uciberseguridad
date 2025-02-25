import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uciberseguridad_app/src/blocs/quiz/quiz_bloc.dart';
import 'package:uciberseguridad_app/src/routes/app_router.dart';
import 'package:uciberseguridad_app/src/blocs/blocs.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

void main() {
  runApp(
    const CyberSecurityApp(),
  );
}

class CyberSecurityApp extends StatelessWidget {
  const CyberSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
        //  BlocProvider(create: (context) => AuthBloc()),
        // BlocProvider(create: (context) => LessonsBloc()),
        BlocProvider(create: (context) => QuizBloc()),
      ],
      child: MaterialApp.router(
        title: 'Cybersecurity Training',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
