import '../domain/nido_domain.dart';

class HistoryReportInput {
  const HistoryReportInput({
    required this.child,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.morningSleep,
    required this.afternoonSleep,
    required this.schoolNotes,
    required this.homeNotes,
  });

  final ChildSummary child;
  final DateTime date;
  final String breakfast;
  final String lunch;
  final String snack;
  final String morningSleep;
  final String afternoonSleep;
  final String? schoolNotes;
  final String? homeNotes;
}

class HistoryEventInput {
  const HistoryEventInput({
    required this.childId,
    required this.date,
  });

  final String? childId;
  final DateTime date;
}

class HistoryMetricsBuilder {
  const HistoryMetricsBuilder._();

  static HistorySummaryData build({
    required List<ChildSummary> children,
    required List<HistoryReportInput> reports,
    required List<HistoryEventInput> attendance,
    required List<HistoryEventInput> messages,
    required List<HistoryEventInput> media,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final uniqueReportDays =
        reports.map((report) => _dayKey(report.date)).toSet();
    final openDays = _weekdayCount(fromDate, toDate);
    final childCount = children.isEmpty ? 1 : children.length;
    final attendancePairs = attendance
        .where((event) => event.childId != null)
        .map((event) => '${event.childId}:${_dayKey(event.date)}')
        .toSet();

    final childrenById = {for (final child in children) child.id: child};
    final classrooms = children.fold<Map<String, List<ChildSummary>>>(
      {},
      (map, child) {
        map.putIfAbsent(child.classroomName, () => []).add(child);
        return map;
      },
    );

    return HistorySummaryData(
      fromDate: fromDate,
      toDate: toDate,
      reportDays: uniqueReportDays.length,
      reportsCount: reports.length,
      attendanceRate: _ratio(attendancePairs.length, openDays * childCount),
      mealScore: _averageMealScore(reports),
      sleepRate: _averageSleepRate(reports),
      messagesCount: messages.length,
      mediaCount: media.length,
      classrooms: [
        for (final entry in classrooms.entries)
          _classroomSummary(
            name: entry.key,
            children: entry.value,
            reports: reports,
            attendance: attendance,
            openDays: openDays,
          ),
      ]..sort((a, b) => a.name.compareTo(b.name)),
      children: [
        for (final child in childrenById.values)
          _childSummary(
            child: child,
            reports:
                reports.where((report) => report.child.id == child.id).toList(),
            attendance: attendance
                .where((event) => event.childId == child.id)
                .map((event) => _dayKey(event.date))
                .toSet()
                .length,
          ),
      ]..sort((a, b) => b.reportsCount.compareTo(a.reportsCount)),
      timeline: _timeline(
        fromDate: fromDate,
        toDate: toDate,
        reports: reports,
        attendance: attendance,
        messages: messages,
        media: media,
      ),
    );
  }

  static ClassroomHistoryData _classroomSummary({
    required String name,
    required List<ChildSummary> children,
    required List<HistoryReportInput> reports,
    required List<HistoryEventInput> attendance,
    required int openDays,
  }) {
    final childIds = children.map((child) => child.id).toSet();
    final classroomReports =
        reports.where((report) => childIds.contains(report.child.id)).toList();
    final attendancePairs = attendance
        .where((event) =>
            event.childId != null && childIds.contains(event.childId))
        .map((event) => '${event.childId}:${_dayKey(event.date)}')
        .toSet();

    return ClassroomHistoryData(
      name: name,
      childrenCount: children.length,
      reportsCount: classroomReports.length,
      attendanceRate:
          _ratio(attendancePairs.length, openDays * children.length),
      mealScore: _averageMealScore(classroomReports),
      sleepRate: _averageSleepRate(classroomReports),
    );
  }

  static ChildHistoryData _childSummary({
    required ChildSummary child,
    required List<HistoryReportInput> reports,
    required int attendance,
  }) {
    final sorted = [...reports]..sort((a, b) => b.date.compareTo(a.date));
    String? latestWithNote;
    for (final report in sorted) {
      final note = report.schoolNotes ?? report.homeNotes ?? '';
      if (note.trim().isNotEmpty) {
        latestWithNote = note;
        break;
      }
    }

    return ChildHistoryData(
      child: child,
      reportsCount: reports.length,
      attendanceDays: attendance,
      mealScore: _averageMealScore(reports),
      sleepRate: _averageSleepRate(reports),
      lastNote: latestWithNote?.trim() ?? 'Sin observaciones recientes',
    );
  }

  static List<HistoryDayData> _timeline({
    required DateTime fromDate,
    required DateTime toDate,
    required List<HistoryReportInput> reports,
    required List<HistoryEventInput> attendance,
    required List<HistoryEventInput> messages,
    required List<HistoryEventInput> media,
  }) {
    final days = <HistoryDayData>[];
    var cursor = _dateOnly(toDate).subtract(const Duration(days: 13));
    final first = _dateOnly(fromDate);
    if (cursor.isBefore(first)) cursor = first;

    while (!cursor.isAfter(toDate)) {
      final key = _dayKey(cursor);
      days.add(
        HistoryDayData(
          date: cursor,
          reportsCount: reports.where((row) => _dayKey(row.date) == key).length,
          attendanceCount: attendance
              .where((row) => _dayKey(row.date) == key && row.childId != null)
              .map((row) => row.childId)
              .toSet()
              .length,
          messagesCount:
              messages.where((row) => _dayKey(row.date) == key).length,
          mediaCount: media.where((row) => _dayKey(row.date) == key).length,
        ),
      );
      cursor = cursor.add(const Duration(days: 1));
    }

    return days;
  }

  static double _averageMealScore(List<HistoryReportInput> reports) {
    if (reports.isEmpty) return 0;
    final values = [
      for (final report in reports) ...[
        _mealScore(report.breakfast),
        _mealScore(report.lunch),
        _mealScore(report.snack),
      ],
    ];
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _averageSleepRate(List<HistoryReportInput> reports) {
    if (reports.isEmpty) return 0;
    final values = [
      for (final report in reports) ...[
        report.morningSleep == 'Bien' ? 1.0 : 0.0,
        report.afternoonSleep == 'Bien' ? 1.0 : 0.0,
      ],
    ];
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _mealScore(String value) {
    return switch (value) {
      'Todo' => 1,
      'Bastante' => 0.75,
      'Poco' => 0.4,
      _ => 0,
    };
  }

  static double _ratio(int value, int total) {
    if (total <= 0) return 0;
    return value / total;
  }

  static int _weekdayCount(DateTime fromDate, DateTime toDate) {
    var count = 0;
    var cursor = _dateOnly(fromDate);
    final end = _dateOnly(toDate);
    while (!cursor.isAfter(end)) {
      if (cursor.weekday <= DateTime.friday) count += 1;
      cursor = cursor.add(const Duration(days: 1));
    }
    return count == 0 ? 1 : count;
  }

  static String _dayKey(DateTime value) {
    return _dateOnly(value).toIso8601String().substring(0, 10);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
