import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_notifier.dart';
import 'models.dart';
import 'setup_view.dart';
import 'theme.dart';
import 'timer_view.dart';
import 'past_sessions.dart';
import 'summary_card.dart';
import 'week_chart.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  Tracker tracker = Tracker.study;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appProvider.notifier).checkRollover();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tickProvider);
    final s = ref.watch(appProvider);
    final now = DateTime.now();
    final day = s.day(tracker);
    if (s.date != dayKey(now)) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ref.read(appProvider.notifier).checkRollover());
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('StudyBlock', style: syne(22, weight: FontWeight.w800)),
                    const Spacer(),
                    Text('🔥 ${s.streak(Tracker.study, now)}',
                        style: mono(14, color: C.blue, weight: FontWeight.bold)),
                    const SizedBox(width: 14),
                    Text('🌱 ${s.streak(Tracker.skill, now)}',
                        style: mono(14, color: C.green, weight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    for (final t in Tracker.values) ...[
                      Expanded(child: _tab(t)),
                      if (t == Tracker.study) const SizedBox(width: 10),
                    ]
                  ]),
                  const SizedBox(height: 20),
                                    Expanded(
                    child: SingleChildScrollView(
                      child: Column(children: [
                        day.sessions.isEmpty
                            ? SetupView(key: ValueKey('setup$tracker'), tracker: tracker)
                            : TimerView(key: ValueKey('timer$tracker'), tracker: tracker),
                        const SizedBox(height: 24),
                        const SummaryCard(),
                        const SizedBox(height: 16),
                        const WeekChart(),
                        const SizedBox(height: 16),
                        const PastSessions(),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(Tracker t) {
    final sel = t == tracker;
    return GestureDetector(
      onTap: () => setState(() => tracker = t),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? C.surface : Colors.transparent,
          border: Border.all(color: sel ? trackerColor(t) : C.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(trackerLabel(t),
            style: syne(13, color: sel ? trackerColor(t) : C.muted, weight: FontWeight.bold)),
      ),
    );
  }
}