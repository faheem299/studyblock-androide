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

  void _checkGoal(Session? cur, DateTime now) {
    if (cur == null || _announcing || cur.announced || !cur.goalMet(now)) return;
    _announcing = true;
    final id = cur.id;
    final goal = cur.goalHours;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appProvider.notifier).markGoalAnnounced(t, id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: trackerColor(t),
        content: Text('🎉 $goal h session goal reached!',
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
    final total = day.totalMs(now);
    final cur = day.current;
    final running = cur?.isRunning ?? false;
    final color = trackerColor(t);

    final sessGoal = cur?.goalHours ?? 1;
    final sessMs = cur?.elapsedMs(now) ?? 0;
    final sessGoalMs = sessGoal * msPerHour;
    final pct = sessMs * 100 ~/ sessGoalMs;

    _checkGoal(cur, now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SESSION ${day.sessions.length} · ${running ? 'LIVE' : 'PAUSED'}',
            style: syne(11, color: running ? color : C.muted)
                .copyWith(letterSpacing: 3)),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(fmt(sessMs), style: display(112)),
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          color: C.border,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (sessMs / sessGoalMs).clamp(0.0, 1.0),
            child: Container(color: color),
          ),
        ),
        const SizedBox(height: 8),
        Text('$pct% of $sessGoal h session goal', style: mono(12, color: C.muted)),
        const SizedBox(height: 2),
        Text('Today ${fmt(total)}', style: mono(11, color: C.muted)),
        if (cur?.goalMet(now) ?? false) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
            child: Text('SESSION GOAL REACHED. KEEP GOING.',
                textAlign: TextAlign.center, style: syne(14, color: color)),
          ),
        ],
        const SizedBox(height: 20),
        Text('NO DAYS OFF.\nOWN THE HOUR.', style: display(52, spacing: 0)),
        const SizedBox(height: 20),
        MinuteGrid(tracker: t),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: C.text,
              foregroundColor: C.bg,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () => ref.read(appProvider.notifier).togglePause(t),
            child: Text(running ? 'PAUSE' : 'RESUME',
                style: syne(18, color: C.bg, weight: FontWeight.w800)
                    .copyWith(letterSpacing: 3)),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color, width: 2),
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: () => _newSession(sessGoal),
                child: Text('+ NEW SESSION',
                    style: syne(13, color: color, weight: FontWeight.w800)),
              ),
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
          child: Text('± ADJUST MINUTES', style: syne(11, color: C.muted)),
        ),
        const SizedBox(height: 16),
        SessionsList(tracker: t),
      ],
    );
  }
}