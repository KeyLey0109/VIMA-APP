import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/transaction_entity.dart';
import 'animated_rainbow.dart';

class SpendingChart extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final int month;
  final int year;

  const SpendingChart({
    super.key,
    required this.transactions,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Chưa có dữ liệu chi tiêu',
            style: AppTextStyles.bodySmall,
          ),
        ),
      );
    }

    final dailySpending = _getDailySpending();
    final spots = dailySpending.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 24, 10),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 500000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1000000,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  String text = '';
                  if (value >= 1000000) {
                    text = '${(value / 1000000).toStringAsFixed(1)}M';
                  } else {
                    text = '${(value / 1000).toInt()}k';
                  }
                  return AnimatedRainbow(
                    child: Text(
                      text,
                      style: AppTextStyles.caption.copyWith(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 1,
          maxX: 31,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: AppColors.chartGradient,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, double> _getDailySpending() {
    final Map<int, double> daily = {};
    for (int i = 1; i <= 31; i++) {
      daily[i] = 0.0;
    }

    for (var tx in transactions) {
      if (tx.dateTime.month == month && tx.dateTime.year == year) {
        final day = tx.dateTime.day;
        daily[day] = (daily[day] ?? 0.0) + tx.amount;
      }
    }
    return daily;
  }
}
