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
  final bool announced; // goal-reached toast already shown

  const Session({
    required this.id,
    required this.startedAt,
    required this.goalHours,
    this.accumulatedMs = 0,
    this.runningSince,
    this.ended = false,
    this.announced = false,
  });

  factory Session.begin(int goalHours, DateTime now) => Session(
        id: now.microsecondsSinceEpoch.toString(),
        startedAt: now,
        goalHours: goalHours,
        runningSince: now,
      );

  bool get isRunning => runningSince != null;
  int get goalMs => goalHours * msPerHour;

  int elapsedMs(DateTime now) =>
      accumulatedMs +
      (runningSince == null ? 0 : max(0, now.difference(runningSince!).inMilliseconds));

  bool goalMet(DateTime now) => elapsedMs(now) >= goalMs;

  Session copyWith({
    int? accumulatedMs,
    DateTime? runningSince,
    bool clearRunning = false,
    bool? ended,
    bool? announced,
  }) =>
      Session(
        id: id,
        startedAt: startedAt,
        goalHours: goalHours,
        accumulatedMs: accumulatedMs ?? this.accumulatedMs,
        runningSince: clearRunning ? null : (runningSince ?? this.runningSince),
        ended: ended ?? this.ended,
        announced: announced ?? this.announced,
      );

  Session paused(DateTime now) =>
      copyWith(accumulatedMs: elapsedMs(now), clearRunning: true);

  Session resumed(DateTime now) => isRunning ? this : copyWith(runningSince: now);

  Session adjusted(int deltaMs, DateTime now) {
    final e = max(0, elapsedMs(now) + deltaMs);
    final base = isRunning
        ? copyWith(accumulatedMs: e, runningSince: now)
        : copyWith(accumulatedMs: e);
    return e >= goalMs ? base : base.copyWith(announced: false);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'goalHours': goalHours,
        'accumulatedMs': accumulatedMs,
        'runningSince': runningSince?.toIso8601String(),
        'ended': ended,
        'announced': announced,
      };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        id: j['id'],
        startedAt: DateTime.parse(j['startedAt']),
        goalHours: j['goalHours'],
        accumulatedMs: j['accumulatedMs'],
        runningSince:
            j['runningSince'] == null ? null : DateTime.parse(j['runningSince']),
        ended: j['ended'],
        announced: j['announced'] ?? false,
      );
}

class TrackerDay {
  final List<Session> sessions; // empty = show setup screen

  const TrackerDay({this.sessions = const []});

  Session? get current =>
      sessions.isNotEmpty && !sessions.last.ended ? sessions.last : null;

  int totalMs(DateTime now) => sessions.fold(0, (a, s) => a + s.elapsedMs(now));

  int reachedCount(DateTime now) => sessions.where((s) => s.goalMet(now)).length;

  /// Today counts toward the streak once any session reached its goal.
  bool streakOk(DateTime now) => sessions.any((s) => s.goalMet(now));

  TrackerDay copyWith({List<Session>? sessions}) =>
      TrackerDay(sessions: sessions ?? this.sessions);

  TrackerDay replaceCurrent(Session s) =>
      copyWith(sessions: [...sessions.sublist(0, sessions.length - 1), s]);

  Map<String, dynamic> toJson() =>
      {'sessions': sessions.map((s) => s.toJson()).toList()};

  factory TrackerDay.fromJson(Map<String, dynamic> j) => TrackerDay(
        sessions:
            ((j['sessions'] ?? []) as List).map((e) => Session.fromJson(e)).toList(),
      );
}

class DayRecord {
  final String date;
  final int studyMs, skillMs;
  final int studySessions, skillSessions;
  final int studyReached, skillReached; // sessions that reached their goal

  const DayRecord({
    required this.date,
    this.studyMs = 0,
    this.skillMs = 0,
    this.studySessions = 0,
    this.skillSessions = 0,
    this.studyReached = 0,
    this.skillReached = 0,
  });

  int ms(Tracker t) => t == Tracker.study ? studyMs : skillMs;
  int sessions(Tracker t) => t == Tracker.study ? studySessions : skillSessions;
  int reached(Tracker t) => t == Tracker.study ? studyReached : skillReached;

  /// Met = at least one session reached its goal.
  bool met(Tracker t) => reached(t) > 0;

  DayRecord add(Tracker t, int ms, int n, int reached) {
    final st = t == Tracker.study;
    return DayRecord(
      date: date,
      studyMs: studyMs + (st ? ms : 0),
      skillMs: skillMs + (st ? 0 : ms),
      studySessions: studySessions + (st ? n : 0),
      skillSessions: skillSessions + (st ? 0 : n),
      studyReached: studyReached + (st ? reached : 0),
      skillReached: skillReached + (st ? 0 : reached),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'studyMs': studyMs,
        'skillMs': skillMs,
        'studySessions': studySessions,
        'skillSessions': skillSessions,
        'studyReached': studyReached,
        'skillReached': skillReached,
      };

  factory DayRecord.fromJson(Map<String, dynamic> j) => DayRecord(
        date: j['date'],
        studyMs: j['studyMs'] ?? 0,
        skillMs: j['skillMs'] ?? 0,
        studySessions: j['studySessions'] ?? 0,
        skillSessions: j['skillSessions'] ?? 0,
        studyReached: j['studyReached'] ?? 0,
        skillReached: j['skillReached'] ?? 0,
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
    var count = day(t).streakOk(now) ? 1 : 0;
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