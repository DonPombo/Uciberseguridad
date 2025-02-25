import 'package:flutter/material.dart';
import 'package:uciberseguridad_app/src/widgets/appbar_screen.dart';
import 'package:uciberseguridad_app/theme/app_theme.dart';
import 'package:uciberseguridad_app/src/widgets/side_menu.dart';
import 'widgets/home_header.dart';
import 'widgets/lessons_section.dart';
import 'widgets/study_plan_section.dart';
import 'widgets/statistics_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return const Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          drawer: SideMenu(),
          appBar: AppBarScreen(
            title: '',
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(),
                  SizedBox(height: 24),
                  LessonsSection(),
                  SizedBox(height: 24),
                  StudyPlanSection(),
                  SizedBox(height: 24),
                  StatisticsSection(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
