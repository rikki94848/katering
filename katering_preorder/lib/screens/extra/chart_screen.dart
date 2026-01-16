import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grafik Penjualan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: true),
            titlesData: const FlTitlesData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(1, 2),
                  FlSpot(2, 5),
                  FlSpot(3, 4),
                  FlSpot(4, 7),
                  FlSpot(5, 9),
                ],
                isCurved: true,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
