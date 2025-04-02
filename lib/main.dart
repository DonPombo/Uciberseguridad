import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uciberseguridad_app/src/blocs/quiz/quiz_bloc.dart';
import 'package:uciberseguridad_app/src/routes/app_router.dart';
import 'package:uciberseguridad_app/src/blocs/blocs.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lcmvtdpmgtjswtlrhkov.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjbXZ0ZHBtZ3Rqc3d0bHJoa292Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NTYyNjcsImV4cCI6MjA1OTAzMjI2N30.jSAczxlZwQE_LViN-yCbyIvDpgaMIAlcbXToSAGGvTE',
  );
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
