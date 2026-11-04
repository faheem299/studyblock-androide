// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'app_notifier.dart';
// import 'history.dart';
// import 'models.dart';
// import 'theme.dart';

// class WeekChart extends ConsumerWidget {
//   const WeekChart({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(tickProvider);
//     final s = ref.watch(appProvider);
//     final now = DateTime.now();

//     final days = [
//       for (var i = 6; i >= 0; i--) DateTime(now.year, now.month, now.day - i)
//     ];
//     final recs = [for (final d in days) recordFor(s, d, now)];

//     Color barColor(Tracker t, DayRecord r) {
//       final c = trackerColor(t);
//       return r.met(t) ? c : Color.lerp(c, C.bg, 0.65)!;
//     }

//     var maxH = 1.0;
//     final groups = <BarChartGroupData>[];
//     for (var i = 0; i < 7; i++) {
//       final r = recs[i];
//       final st = r.studyMs / msPerHour;
//       final sk = r.skillMs / msPerHour;
//       if (st > maxH) maxH = st;
//       if (sk > maxH) maxH = sk;
//       groups.add(BarChartGroupData(x: i, barsSpace: 3, barRods: [
//         BarChartRodData(
//             toY: st,
//             width: 9,
//             color: barColor(Tracker.study, r),
//             borderRadius: BorderRadius.circular(2)),
//         BarChartRodData(
//             toY: sk,
//             width: 9,
//             color: barColor(Tracker.skill, r),
//             borderRadius: BorderRadius.circular(2)),
//       ]));
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//       decoration: BoxDecoration(
//         color: C.surface,
//         border: Border.all(color: C.border),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Text('LAST 7 DAYS (hours)',
//               style: mono(11, color: C.muted, weight: FontWeight.bold)),
//           const Spacer(),
//           Text('■ ', style: mono(11, color: C.blue)),
//           Text('study  ', style: mono(10, color: C.muted)),
//           Text('■ ', style: mono(11, color: C.green)),
//           Text('skill', style: mono(10, color: C.muted)),
//         ]),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 160,
//           child: BarChart(BarChartData(
//             maxY: maxH * 1.15,
//             minY: 0,
//             barGroups: groups,
//             gridData: const FlGridData(show: false),
//             borderData: FlBorderData(show: false),
//             titlesData: FlTitlesData(
//               leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 24,
//                   getTitlesWidget: (v, meta) => Padding(
//                     padding: const EdgeInsets.only(top: 6),
//                     child: Text(DateFormat('E').format(days[v.toInt()]),
//                         style: mono(10,
//                             color: v.toInt() == 6 ? C.text : C.muted)),
//                   ),
//                 ),
//               ),
//             ),
//           )),
//         ),
//         const SizedBox(height: 4),
//         Text('Dimmed bars = goal missed', style: mono(10, color: C.muted)),
//       ]),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'app_notifier.dart';
import 'history.dart';
import 'models.dart';
import 'theme.dart';

class WeekChart extends ConsumerWidget {
  const WeekChart({super.key});

  static const double _barArea = 140; // max bar height
  static const double _labelArea = 90; // room for the rotated duration label
  static const double _barWidth = 25;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickProvider);
    final s = ref.watch(appProvider);
    final now = DateTime.now();

    final days = [
      for (var i = 6; i >= 0; i--) DateTime(now.year, now.month, now.day - i)
    ];
    final recs = [for (final d in days) recordFor(s, d, now)];

    var maxMs = msPerHour; // scale is at least 1 hour
    for (final r in recs) {
      if (r.studyMs > maxMs) maxMs = r.studyMs;
      if (r.skillMs > maxMs) maxMs = r.skillMs;
    }

    Widget bar(Tracker t, DayRecord r) {
      final ms = r.ms(t);
      final base = trackerColor(t);
      final color = r.met(t) ? base : Color.lerp(base, C.bg, 0.65)!;
      final h = ms == 0
          ? 2.0
          : (ms / maxMs * _barArea).clamp(4.0, _barArea).toDouble();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ms > 0)
            RotatedBox(
              quarterTurns: 3,
              child: Text(fmtHm(ms), maxLines: 1, style: mono(9)),
            ),
          const SizedBox(height: 3),
          Container(
            width: _barWidth,
            height: h,
            decoration: BoxDecoration(
              color: ms == 0 ? C.border : color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      );
    }

    Widget dayCol(int i) {
      final r = recs[i];
      return Expanded(
        child: Column(children: [
          SizedBox(
            height: _labelArea + _barArea + 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                bar(Tracker.study, r),
                const SizedBox(width: 3),
                bar(Tracker.skill, r),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(DateFormat('E').format(days[i]),
              style: mono(10, color: i == 6 ? C.text : C.muted)),
        ]),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: C.surface,
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('LAST 7 DAYS',
              style: mono(11, color: C.muted, weight: FontWeight.bold)),
          const Spacer(),
          Text('■ ', style: mono(11, color: C.blue)),
          Text('study  ', style: mono(10, color: C.muted)),
          Text('■ ', style: mono(11, color: C.green)),
          Text('skill', style: mono(10, color: C.muted)),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < 7; i++) dayCol(i),
        ]),
        const SizedBox(height: 8),
        Text('Dimmed bars = goal missed', style: mono(10, color: C.muted)),
      ]),
    );
  }
}