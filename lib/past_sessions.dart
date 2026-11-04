import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'app_notifier.dart';
import 'history.dart';
import 'models.dart';
import 'theme.dart';

class PastSessions extends ConsumerWidget {
  const PastSessions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appProvider);
    final recs = s.history.where((r) => r.date != s.date).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final shown = recs.take(14).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('PAST SESSIONS',
            style: mono(11, color: C.muted, weight: FontWeight.bold)),
        const Spacer(),
        if (s.history.isNotEmpty)
          GestureDetector(
            onTap: () => _confirmClear(context, ref),
            child: Text('Clear all', style: mono(11, color: C.muted)),
          ),
      ]),
      const SizedBox(height: 8),
      if (shown.isEmpty)
        Text('No past days yet.', style: mono(12, color: C.muted)),
      for (final r in shown)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.surface,
            border: Border.all(color: C.border),
            borderRadius: BorderRadius.zero,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DateFormat('EEE, MMM d').format(parseDayKey(r.date)),
                style: syne(13, weight: FontWeight.w800)),
            for (final t in Tracker.values)
              if (r.sessions(t) > 0) _row(r, t),
          ]),
        ),
    ]);
  }

  Widget _row(DayRecord r, Tracker t) {
    final color = trackerColor(t);
    final n = r.sessions(t);
    final frac = n == 0 ? 0.0 : r.reached(t) / n;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(t == Tracker.study ? '📘' : '🌱', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(fmtHm(r.ms(t)), style: mono(11, color: r.met(t) ? color : C.text)),
          const Spacer(),
          Text('${r.reached(t)}/$n goals · $n session${n == 1 ? '' : 's'}',
              style: mono(10, color: C.muted)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 10,
            backgroundColor: C.border,
            color: color,
          ),
        ),
      ]),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('Clear all history?', style: syne(18, weight: FontWeight.w800)),
        content: Text('This wipes past days and resets your streaks.',
            style: mono(12, color: C.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: mono(12, color: C.muted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: syne(14, color: C.bg, weight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(appProvider.notifier).clearHistory();
  }
}