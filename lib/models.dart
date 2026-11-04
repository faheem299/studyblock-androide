import 'dart:math';

enum Tracker { study, skill }

const msPerHour = 3600000;

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDayKey(String k) {
  final p = k.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

String fmt(int ms) {
  final s = ms ~/ 1000;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(s ~/ 3600)}:${two(s % 3600 ~/ 60)}:${two(s % 60)}';
}

class Session {
  final String id;
  final DateTime startedAt;
  final int goalHours;
  final int accumulatedMs;
  final DateTime? runningSince; // null = paused
  final bool ended;

  const Session({
    required this.id,
    required this.startedAt,
    required this.goalHours,
    this.accumulatedMs = 0,
    this.runningSince,
    this.ended = false,
  });

  factory Session.begin(int goalHours, DateTime now) => Session(
        id: now.microsecondsSinceEpoch.toString(),
        startedAt: now,
        goalHours: goalHours,
        runningSince: now,
      );

  bool get isRunning => runningSince != null;

  int elapsedMs(DateTime now) =>
      accumulatedMs +
      (runningSince == null ? 0 : max(0, now.difference(runningSince!).inMilliseconds));

  Session copyWith({
    int? accumulatedMs,
    DateTime? runningSince,
    bool clearRunning = false,
    bool? ended,
  }) =>
      Session(
        id: id,
        startedAt: startedAt,
        goalHours: goalHours,
        accumulatedMs: accumulatedMs ?? this.accumulatedMs,
        runningSince: clearRunning ? null : (runningSince ?? this.runningSince),
        ended: ended ?? this.ended,
      );

  Session paused(DateTime now) =>
      copyWith(accumulatedMs: elapsedMs(now), clearRunning: true);

  Session resumed(DateTime now) => isRunning ? this : copyWith(runningSince: now);

  Session adjusted(int deltaMs, DateTime now) {
    final e = max(0, elapsedMs(now) + deltaMs);
    return isRunning
        ? copyWith(accumulatedMs: e, runningSince: now)
        : copyWith(accumulatedMs: e);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'goalHours': goalHours,
        'accumulatedMs': accumulatedMs,
        'runningSince': runningSince?.toIso8601String(),
        'ended': ended,
      };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        id: j['id'],
        startedAt: DateTime.parse(j['startedAt']),
        goalHours: j['goalHours'],
        accumulatedMs: j['accumulatedMs'],
        runningSince:
            j['runningSince'] == null ? null : DateTime.parse(j['runningSince']),
        ended: j['ended'],
      );
}

class TrackerDay {
  final int? goalHours; // null = setup screen
  final List<Session> sessions;
  final bool goalAnnounced;

  const TrackerDay({this.goalHours, this.sessions = const [], this.goalAnnounced = false});

  Session? get current =>
      sessions.isNotEmpty && !sessions.last.ended ? sessions.last : null;

  int totalMs(DateTime now) => sessions.fold(0, (a, s) => a + s.elapsedMs(now));

  bool goalMet(DateTime now) =>
      goalHours != null && totalMs(now) >= goalHours! * msPerHour;

  TrackerDay copyWith({int? goalHours, List<Session>? sessions, bool? goalAnnounced}) =>
      TrackerDay(
        goalHours: goalHours ?? this.goalHours,
        sessions: sessions ?? this.sessions,
        goalAnnounced: goalAnnounced ?? this.goalAnnounced,
      );

  TrackerDay replaceCurrent(Session s) =>
      copyWith(sessions: [...sessions.sublist(0, sessions.length - 1), s]);

  Map<String, dynamic> toJson() => {
        'goalHours': goalHours,
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'goalAnnounced': goalAnnounced,
      };

  factory TrackerDay.fromJson(Map<String, dynamic> j) => TrackerDay(
        goalHours: j['goalHours'],
        sessions: (j['sessions'] as List).map((e) => Session.fromJson(e)).toList(),
        goalAnnounced: j['goalAnnounced'],
      );
}

class DayRecord {
  final String date;
  final int studyMs, skillMs, studyGoal, skillGoal, studySessions, skillSessions;

  const DayRecord({
    required this.date,
    this.studyMs = 0,
    this.skillMs = 0,
    this.studyGoal = 0,
    this.skillGoal = 0,
    this.studySessions = 0,
    this.skillSessions = 0,
  });

  int ms(Tracker t) => t == Tracker.study ? studyMs : skillMs;
  int goal(Tracker t) => t == Tracker.study ? studyGoal : skillGoal;
  int sessions(Tracker t) => t == Tracker.study ? studySessions : skillSessions;
  bool met(Tracker t) => goal(t) > 0 && ms(t) >= goal(t) * msPerHour;

  DayRecord add(Tracker t, int ms, int goal, int n) => t == Tracker.study
      ? DayRecord(
          date: date,
          studyMs: studyMs + ms,
          skillMs: skillMs,
          studyGoal: max(studyGoal, goal),
          skillGoal: skillGoal,
          studySessions: studySessions + n,
          skillSessions: skillSessions)
      : DayRecord(
          date: date,
          studyMs: studyMs,
          skillMs: skillMs + ms,
          studyGoal: studyGoal,
          skillGoal: max(skillGoal, goal),
          studySessions: studySessions,
          skillSessions: skillSessions + n);

  Map<String, dynamic> toJson() => {
        'date': date,
        'studyMs': studyMs,
        'skillMs': skillMs,
        'studyGoal': studyGoal,
        'skillGoal': skillGoal,
        'studySessions': studySessions,
        'skillSessions': skillSessions,
      };

  factory DayRecord.fromJson(Map<String, dynamic> j) => DayRecord(
        date: j['date'],
        studyMs: j['studyMs'],
        skillMs: j['skillMs'],
        studyGoal: j['studyGoal'],
        skillGoal: j['skillGoal'],
        studySessions: j['studySessions'],
        skillSessions: j['skillSessions'],
      );
}

class AppData {
  final String date;
  final TrackerDay study, skill;
  final List<DayRecord> history;

  const AppData({
    required this.date,
    this.study = const TrackerDay(),
    this.skill = const TrackerDay(),
    this.history = const [],
  });

  TrackerDay day(Tracker t) => t == Tracker.study ? study : skill;

  AppData withDay(Tracker t, TrackerDay d) =>
      t == Tracker.study ? copyWith(study: d) : copyWith(skill: d);

  AppData copyWith({
    String? date,
    TrackerDay? study,
    TrackerDay? skill,
    List<DayRecord>? history,
  }) =>
      AppData(
        date: date ?? this.date,
        study: study ?? this.study,
        skill: skill ?? this.skill,
        history: history ?? this.history,
      );

  /// Consecutive days meeting goal, derived from history (max 60 days kept).
  int streak(Tracker t, DateTime now) {
    final byDate = {for (final r in history) r.date: r};
    var count = day(t).goalMet(now) ? 1 : 0;
    var d = DateTime(now.year, now.month, now.day - 1);
    while (byDate[dayKey(d)]?.met(t) ?? false) {
      count++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return count;
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'study': study.toJson(),
        'skill': skill.toJson(),
        'history': history.map((r) => r.toJson()).toList(),
      };

  factory AppData.fromJson(Map<String, dynamic> j) => AppData(
        date: j['date'],
        study: TrackerDay.fromJson(j['study']),
        skill: TrackerDay.fromJson(j['skill']),
        history: (j['history'] as List).map((e) => DayRecord.fromJson(e)).toList(),
      );
}