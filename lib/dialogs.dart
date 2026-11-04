import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'theme.dart';

Future<int?> showGoalDialog(BuildContext context, Tracker tracker, int initial) {
  var goal = initial;
  final color = trackerColor(tracker);
  return showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('New session goal (hours)',
            style: syne(18, weight: FontWeight.w800)),
        content: Wrap(spacing: 8, runSpacing: 8, children: [
          for (var h = 1; h <= 12; h++)
            GestureDetector(
              onTap: () => setState(() => goal = h),
              child: Container(
                width: 48,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: goal == h ? color : C.bg,
                  border: Border.all(color: goal == h ? color : C.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$h',
                    style: mono(14,
                        color: goal == h ? C.bg : C.text, weight: FontWeight.bold)),
              ),
            ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: mono(12, color: C.muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: C.bg),
            onPressed: () => Navigator.pop(ctx, goal),
            child: Text('Start', style: syne(14, color: C.bg, weight: FontWeight.w800)),
          ),
        ],
      ),
    ),
  );
}

/// Returns minutes to add (positive) or remove (negative), or null if cancelled.
Future<int?> showAdjustDialog(BuildContext context, Tracker tracker) {
  final ctrl = TextEditingController();
  final color = trackerColor(tracker);
  int? minutes() {
    final m = int.tryParse(ctrl.text);
    return (m == null || m == 0) ? null : m;
  }

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: C.surface,
      title: Text('Adjust minutes', style: syne(18, weight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Remove time you forgot to stop, or add some back to the current session.',
            style: mono(12, color: C.muted)),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: mono(16),
          decoration: const InputDecoration(hintText: 'minutes', suffixText: 'min'),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel', style: mono(12, color: C.muted)),
        ),
        TextButton(
          onPressed: () {
            final m = minutes();
            Navigator.pop(ctx, m == null ? null : -m);
          },
          child: Text('− Remove', style: mono(12, color: color, weight: FontWeight.bold)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: C.bg),
          onPressed: () => Navigator.pop(ctx, minutes()),
          child: Text('+ Add', style: syne(14, color: C.bg, weight: FontWeight.w800)),
        ),
      ],
    ),
  );
}

Future<bool> confirmReset(BuildContext context, Tracker tracker) async {
  final color = trackerColor(tracker);
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: C.surface,
      title: Text('Reset today?', style: syne(18, weight: FontWeight.w800)),
      content: Text(
        "Today's ${tracker.name} data will be archived and you'll return to setup.",
        style: mono(12, color: C.muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Cancel', style: mono(12, color: C.muted)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: C.bg),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Reset', style: syne(14, color: C.bg, weight: FontWeight.w800)),
        ),
      ],
    ),
  );
  return r ?? false;
}