import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'app_notifier.dart';
import 'models.dart';
import 'theme.dart';

class SessionsList extends ConsumerWidget {
  final Tracker tracker;
  const SessionsList({super.key, required this.tracker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickProvider);
    final day = ref.watch(appProvider).day(tracker);
    final now = DateTime.now();
    final color = trackerColor(tracker);
    final curId = day.current?.id;
    final fmtTime = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TODAY'S SESSIONS",
            style: mono(11, color: C.muted, weight: FontWeight.bold)),
        const SizedBox(height: 8),
        for (final s in day.sessions.reversed)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: C.surface,
              border: Border.all(color: s.id == curId ? color : C.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Text(fmtTime.format(s.startedAt), style: mono(12, color: C.muted)),
              const SizedBox(width: 10),
              Text('${s.goalHours}h', style: mono(11, color: C.muted)),
              const Spacer(),
              if (s.id == curId) ...[
                Text(s.isRunning ? '● LIVE' : 'PAUSED',
                    style: mono(10,
                        color: s.isRunning ? color : C.muted, weight: FontWeight.bold)),
                const SizedBox(width: 10),
              ],
              Text(fmt(s.elapsedMs(now)), style: mono(14, weight: FontWeight.bold)),
            ]),
          ),
      ],
    );
  }
}