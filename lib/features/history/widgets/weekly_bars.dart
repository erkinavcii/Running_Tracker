import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/weeks.dart';

/// Flat bar chart of distance per week; the current week is highlighted.
class WeeklyBars extends StatelessWidget {
  final List<(DateTime, double)> weeks; // oldest first
  final bool miles;

  const WeeklyBars({super.key, required this.weeks, required this.miles});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final max = weeks.fold(0.0, (m, w) => w.$2 > m ? w.$2 : m);
    const barArea = 72.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: barArea + 26, // room for the value label above the tallest bar
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < weeks.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (i == weeks.length - 1 && weeks[i].$2 > 0)
                          FittedBox(
                            child: Text(
                              formatDistance(weeks[i].$2, miles: miles),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: c.accent,
                                fontFeatures: tabularFigures,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: max <= 0
                              ? 3
                              : (barArea * weeks[i].$2 / max).clamp(3, barArea),
                          decoration: BoxDecoration(
                            color: i == weeks.length - 1
                                ? c.accent
                                : (weeks[i].$2 > 0 ? c.muted : c.line),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              shortDay(weeks.first.$1),
              style: TextStyle(fontSize: 11, color: c.muted),
            ),
            const Spacer(),
            Text('This week', style: TextStyle(fontSize: 11, color: c.muted)),
          ],
        ),
      ],
    );
  }
}
