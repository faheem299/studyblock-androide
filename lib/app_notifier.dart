import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'package:flutter/foundation.dart';


final prefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());

final tickProvider = StreamProvider<DateTime>(
  (_) => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
);

final appProvider = NotifierProvider<AppNotifier, AppData>(AppNotifier.new);

class AppNotifier extends Notifier<AppData> {
  static const _key = 'studyblock_v1';

  @override
  AppData build() {
    final raw = ref.read(prefsProvider).getString(_key);
    final now = DateTime.now();
    debugPrint('[StudyBlock] startup: ${raw == null ? 'NOTHING SAVED' : '${raw.length} bytes saved for ${jsonDecode(raw)['date']}'}, today is ${dayKey(now)}');
    final loaded = raw == null
        ? AppData(date: dayKey(now))
        : AppData.fromJson(jsonDecode(raw));
    final rolled = _rolled(loaded, now);
    _save(rolled);
    return rolled;
  }

  Future<void> _save(AppData d) async {
    final ok = await ref.read(prefsProvider).setString(_key, jsonEncode(d.toJson()));
    if (!ok) debugPrint('[StudyBlock] SAVE FAILED');
    
  }

  List<DayRecord> _withDay(
      List<DayRecord> h, String date, Tracker t, TrackerDay day, DateTime at) {
    if (day.sessions.isEmpty) return h;
    final i = h.indexWhere((r) => r.date == date);
    final base = i >= 0 ? h[i] : DayRecord(date: date);
    final upd = base.add(t, day.totalMs(at), day.goalHours ?? 0, day.sessions.length);
    final out = [...h];
    i >= 0 ? out[i] = upd : out.add(upd);
    out.sort((a, b) => a.date.compareTo(b.date));
    return out.length > 60 ? out.sublist(out.length - 60) : out;
  }

  AppData _rolled(AppData d, DateTime now) {
    if (d.date == dayKey(now)) return d;
    final saved = parseDayKey(d.date);
    // Cap running sessions at midnight of the day they belong to.
    final at = DateTime(saved.year, saved.month, saved.day + 1);
    var h = _withDay(d.history, d.date, Tracker.study, d.study, at);
    h = _withDay(h, d.date, Tracker.skill, d.skill, at);
    return AppData(date: dayKey(now), history: h);
  }

  void _update(Tracker t, TrackerDay Function(TrackerDay) f) {
    final now = DateTime.now();
    final rolled = _rolled(state, now);
    state = rolled.withDay(t, f(rolled.day(t)));
    _save(state);
  }

  void checkRollover() {
    final r = _rolled(state, DateTime.now());
    if (!identical(r, state)) {
      state = r;
      _save(state);
    }
  }

  void start(Tracker t, int goalHours) {
    final now = DateTime.now();
    _update(t, (d) => d.copyWith(
          goalHours: goalHours,
          sessions: [...d.sessions, Session.begin(goalHours, now)],
        ));
  }

  void newSession(Tracker t, int goalHours) {
    final now = DateTime.now();
    _update(t, (d) {
      final done = d.sessions
          .map((s) => s.ended ? s : s.paused(now).copyWith(ended: true))
          .toList();
      return d.copyWith(sessions: [...done, Session.begin(goalHours, now)]);
    });
  }
  void togglePause(Tracker t) {
    final now = DateTime.now();
    _update(t, (d) {
      final c = d.current;
      if (c == null) return d;
      return d.replaceCurrent(c.isRunning ? c.paused(now) : c.resumed(now));
    });
  }

  void adjustMinutes(Tracker t, int minutes) {
    final now = DateTime.now();
    _update(t, (d) {
      final c = d.current;
      if (c == null) return d;
      return d.replaceCurrent(c.adjusted(minutes * 60000, now));
    });
  }

  void markGoalAnnounced(Tracker t) =>
      _update(t, (d) => d.copyWith(goalAnnounced: true));

  /// Archives today's data for this tracker, then returns it to setup.
  void reset(Tracker t) {
    final now = DateTime.now();
    final rolled = _rolled(state, now);
    final h = _withDay(rolled.history, rolled.date, t, rolled.day(t), now);
    state = rolled.copyWith(history: h).withDay(t, const TrackerDay());
    _save(state);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
    _save(state);
  }
}