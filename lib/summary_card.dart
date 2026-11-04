import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_notifier.dart';
import 'models.dart';
import 'theme.dart';

class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickProvider);
    final s = ref.watch(appProvider);
    final now = DateTime.now();

    Widget col(Tracker t) {
      final d = s.day(t);
      final color = trackerColor(t);
      return Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t == Tracker.study ? '📘 Study' : '🌱 Skill',
              style: syne(12, color: color, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(fmt(d.totalMs(now)), style: mono(18, weight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${d.sessions.length} session${d.sessions.length == 1 ? '' : 's'}'
            '${d.goalHours == null ? '' : ' · goal ${d.goalHours}h'}',
            style: mono(10, color: C.muted),
          ),
        ]),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TODAY', style: mono(11, color: C.muted, weight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [col(Tracker.study), col(Tracker.skill)]),
      ]),
    );
  }
}