import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_notifier.dart';
import 'dialogs.dart';
import 'minute_grid.dart';
import 'models.dart';
import 'sessions_list.dart';
import 'theme.dart';

class TimerView extends ConsumerStatefulWidget {
  final Tracker tracker;
  const TimerView({super.key, required this.tracker});
  @override
  ConsumerState<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends ConsumerState<TimerView> {
  bool _announcing = false;

  Tracker get t => widget.tracker;

  void _checkGoal(TrackerDay day, DateTime now) {
    if (_announcing || day.goalAnnounced || !day.goalMet(now)) return;
    _announcing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appProvider.notifier).markGoalAnnounced(t);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: trackerColor(t),
        content: Text('🎉 ${day.goalHours}h goal reached! Keep going if you like.',
            style: mono(12, color: C.bg, weight: FontWeight.bold)),
      ));
      _announcing = false;
    });
  }

  Future<void> _newSession(int currentGoal) async {
    final g = await showGoalDialog(context, t, currentGoal);
    if (g != null && mounted) ref.read(appProvider.notifier).newSession(t, g);
  }

  Future<void> _adjust() async {
    final m = await showAdjustDialog(context, t);
    if (m != null && mounted) ref.read(appProvider.notifier).adjustMinutes(t, m);
  }

  Future<void> _reset() async {
    final ok = await confirmReset(context, t);
    if (ok && mounted) ref.read(appProvider.notifier).reset(t);
  }

    @override
  Widget build(BuildContext context) {
    ref.watch(tickProvider);
    final day = ref.watch(appProvider).day(t);
    final now = DateTime.now();
    final dayGoal = day.goalHours ?? 1;
    final total = day.totalMs(now);
    final cur = day.current;
    final running = cur?.isRunning ?? false;
    final color = trackerColor(t);

    final sessGoal = cur?.goalHours ?? dayGoal;
    final sessMs = cur?.elapsedMs(now) ?? 0;
    final sessGoalMs = sessGoal * msPerHour;
    final pct = sessMs * 100 ~/ sessGoalMs;

    _checkGoal(day, now);

    return Column(
      children: [
        Text(running ? '● LIVE' : 'PAUSED',
            style: mono(12, color: running ? color : C.muted, weight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(fmt(sessMs), style: mono(52, weight: FontWeight.bold)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (sessMs / sessGoalMs).clamp(0.0, 1.0),
            minHeight: 14,
            backgroundColor: C.border,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text('$pct% of ${sessGoal}h session goal', style: mono(12, color: C.muted)),
        const SizedBox(height: 4),
        Text('Today ${fmt(total)} / ${dayGoal}h', style: mono(11, color: C.muted)),
        if (day.goalMet(now)) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.surface,
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('🎉 Daily goal reached! You can keep going.',
                textAlign: TextAlign.center,
                style: syne(14, color: color, weight: FontWeight.w800)),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: C.bg,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => ref.read(appProvider.notifier).togglePause(t),
            icon: Icon(running ? Icons.pause : Icons.play_arrow),
            label: Text(running ? 'Pause' : 'Resume',
                style: syne(15, color: C.bg, weight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _newSession(sessGoal),
              child: Text('+ New Session',
                  style: syne(13, color: color, weight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Reset today',
            onPressed: _reset,
            icon: const Icon(Icons.refresh, color: C.muted),
          ),
        ]),
        TextButton(
          onPressed: _adjust,
          child: Text('± adjust minutes', style: mono(12, color: C.muted)),
        ),
        const SizedBox(height: 16),
        MinuteGrid(tracker: t),
        const SizedBox(height: 24),
        SessionsList(tracker: t),
      ],
    );
  }
}