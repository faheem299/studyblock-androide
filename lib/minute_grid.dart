import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_notifier.dart';
import 'models.dart';
import 'theme.dart';

class MinuteGrid extends ConsumerWidget {
  final Tracker tracker;
  const MinuteGrid({super.key, required this.tracker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickProvider);
    final day = ref.watch(appProvider).day(tracker);
    final now = DateTime.now();
    final cur = day.current;
    final goal = cur?.goalHours ?? 1;
    final elapsedMin = (cur?.elapsedMs(now) ?? 0) ~/ 60000;
    final running = cur?.isRunning ?? false;
    final color = trackerColor(tracker);

    return Column(
      children: [
        for (var h = 0; h < goal; h++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              SizedBox(
                width: 24,
                child: elapsedMin >= (h + 1) * 60
                    ? Text('✓', style: mono(12, color: color, weight: FontWeight.bold))
                    : Text('${h + 1}', style: mono(10, color: C.muted)),
              ),
              Expanded(
                child: Row(children: [
                  for (var m = 0; m < 60; m++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.5),
                        child: _cell(h * 60 + m, elapsedMin, running, color),
                      ),
                    ),
                ]),
              ),
            ]),
          ),
      ],
    );
  }

  Widget _cell(int idx, int elapsedMin, bool running, Color color) {
    if (idx == elapsedMin && running) return _PulseCell(color: color);
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: idx < elapsedMin ? color : C.border,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}

class _PulseCell extends StatefulWidget {
  final Color color;
  const _PulseCell({required this.color});
  @override
  State<_PulseCell> createState() => _PulseCellState();
}

class _PulseCellState extends State<_PulseCell> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.25, end: 1.0).animate(_c),
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
}