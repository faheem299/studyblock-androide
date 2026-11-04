import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_notifier.dart';
import 'models.dart';
import 'theme.dart';

class SetupView extends ConsumerStatefulWidget {
  final Tracker tracker;
  const SetupView({super.key, required this.tracker});
  @override
  ConsumerState<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends ConsumerState<SetupView> {
  int goal = 2;

  @override
  Widget build(BuildContext context) {
    final color = trackerColor(widget.tracker);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session goal', style: syne(20, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('How many hours for this session?', style: mono(12, color: C.muted)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var h = 1; h <= 12; h++)
              GestureDetector(
                onTap: () => setState(() => goal = h),
                child: Container(
                  width: 70,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: goal == h ? color : C.surface,
                    border: Border.all(color: goal == h ? color : C.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${h}h',
                      style: mono(15,
                          color: goal == h ? C.bg : C.text, weight: FontWeight.bold)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: C.bg,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => ref.read(appProvider.notifier).start(widget.tracker, goal),
            child: Text('Start', style: syne(16, color: C.bg, weight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}