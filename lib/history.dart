import 'models.dart';

/// Record for a calendar day: archived history, plus live data if it's today.
DayRecord recordFor(AppData s, DateTime day, DateTime now) {
  final k = dayKey(day);
  var r = DayRecord(date: k);
  for (final h in s.history) {
    if (h.date == k) r = h;
  }
  if (k == s.date) {
    for (final t in Tracker.values) {
      final d = s.day(t);
      if (d.sessions.isNotEmpty) {
        r = r.add(t, d.totalMs(now), d.sessions.length, d.reachedCount(now));
      }
    }
  }
  return r;
}

String hoursStr(int ms) => (ms / msPerHour).toStringAsFixed(1);

/// 5400000 ms -> "1 h 30 min", 2700000 -> "45 min", 7200000 -> "2 h"
String fmtHm(int ms) {
  final totalMin = (ms / 60000).round();
  if (ms > 0 && totalMin == 0) return '<1 min';
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}