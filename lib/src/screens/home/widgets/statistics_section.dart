import 'package:flutter/material.dart';
import 'progress_chart.dart';
import 'section_header.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SectionHeader(title: 'Estadísticas'),
        SizedBox(height: 16),
        ProgressChart(),
      ],
    );
  }
}