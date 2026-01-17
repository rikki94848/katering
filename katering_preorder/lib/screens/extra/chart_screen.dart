import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int>? dailyOmzet;

  const ChartScreen({
    super.key,
    this.startDate,
    this.endDate,
    this.dailyOmzet,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late List<int> _data;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    // Gunakan data kiriman, atau list kosong jika null
    _data = widget.dailyOmzet ?? [];

    // Jika data kosong (user belum ada transaksi), buat dummy 0 semua
    if (_data.isEmpty) {
      // Default range 7 hari jika null
      int days = 7;
      if (widget.startDate != null && widget.endDate != null) {
        days = widget.endDate!.difference(widget.startDate!).inDays + 1;
      }
      _data = List.filled(days > 0 ? days : 7, 0);
    }

    _start =
        widget.startDate ?? DateTime.now().subtract(const Duration(days: 6));
    _end = widget.endDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Hitung Nilai Maksimum (maxY)
    // Cari nilai terbesar di data
    int maxVal = 0;
    if (_data.isNotEmpty) {
      maxVal = _data.reduce((curr, next) => curr > next ? curr : next);
    }

    // Tentukan maxY agar grafik tidak gepeng
    // Jika maxVal 0 (belum ada omzet), kita set default 100.000 supaya sumbu Y tetap muncul
    double maxY = (maxVal == 0) ? 100000.0 : (maxVal * 1.2);

    // 2. Tentukan Interval Label
    double xInterval = _data.length > 5 ? (_data.length / 5).toDouble() : 1.0;

    // Perbaikan Penting: yInterval tidak boleh 0
    double yInterval = maxY / 5;
    if (yInterval <= 0)
      yInterval =
          20000.0; // Fallback jika maxY 0 (seharusnya tidak mungkin kena ini krn logic di atas)

    return Scaffold(
      appBar: AppBar(title: const Text("Grafik Penjualan")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Tren Pendapatan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${DateFormat('dd MMM').format(_start)} - ${DateFormat('dd MMM yyyy').format(_end)}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval, // Aman, tidak akan 0
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: xInterval,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < _data.length) {
                            DateTime date = _start.add(Duration(days: idx));
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('d/M').format(date),
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          if (value == 0)
                            return const Text('0',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey));

                          String text;
                          if (value >= 1000000) {
                            text = '${(value / 1000000).toStringAsFixed(1)}jt';
                          } else if (value >= 1000) {
                            text = '${(value / 1000).toStringAsFixed(0)}rb';
                          } else {
                            text = value.toInt().toString();
                          }
                          return Text(
                            text,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                            textAlign: TextAlign.left,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (_data.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(_data.length, (i) {
                        return FlSpot(i.toDouble(), _data[i].toDouble());
                      }),
                      isCurved: true,
                      color: const Color(0xFF7C3AED),
                      barWidth: 3,
                      dotData: FlDotData(show: _data.length < 30),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            const Color(0xFF7C3AED).withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => Colors.blueGrey,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0)
                                .format(barSpot.y),
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
