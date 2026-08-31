import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/src/application/history_metrics.dart';
import 'package:nidoconecta/src/domain/nido_domain.dart';

void main() {
  test('builds center, classroom and child history metrics', () {
    const child = ChildSummary(
      id: 'child-1',
      fullName: 'Aina Ruiz',
      classroomName: 'Petits 0-1',
    );
    final fromDate = DateTime(2026, 9, 1);
    final toDate = DateTime(2026, 9, 5);

    final summary = HistoryMetricsBuilder.build(
      children: const [child],
      reports: [
        HistoryReportInput(
          child: child,
          date: DateTime(2026, 9, 1),
          breakfast: 'Todo',
          lunch: 'Bastante',
          snack: 'Poco',
          morningSleep: 'Bien',
          afternoonSleep: 'Bien',
          schoolNotes: 'Dia tranquilo',
          homeNotes: null,
        ),
        HistoryReportInput(
          child: child,
          date: DateTime(2026, 9, 2),
          breakfast: 'Todo',
          lunch: 'Todo',
          snack: 'Bastante',
          morningSleep: 'Bien',
          afternoonSleep: 'No',
          schoolNotes: null,
          homeNotes: 'Descanso irregular',
        ),
      ],
      attendance: [
        HistoryEventInput(childId: child.id, date: DateTime(2026, 9, 1)),
        HistoryEventInput(childId: child.id, date: DateTime(2026, 9, 2)),
      ],
      messages: [
        HistoryEventInput(childId: child.id, date: DateTime(2026, 9, 2)),
      ],
      media: [
        HistoryEventInput(childId: child.id, date: DateTime(2026, 9, 3)),
      ],
      fromDate: fromDate,
      toDate: toDate,
    );

    expect(summary.reportsCount, 2);
    expect(summary.reportDays, 2);
    expect(summary.messagesCount, 1);
    expect(summary.mediaCount, 1);
    expect(summary.classrooms.single.name, 'Petits 0-1');
    expect(summary.children.single.lastNote, 'Descanso irregular');
    expect(summary.attendanceRate, closeTo(0.5, 0.01));
    expect(summary.sleepRate, closeTo(0.75, 0.01));
  });
}
