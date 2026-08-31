import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/src/application/daily_report_payloads.dart';

void main() {
  test('builds a school daily report payload for Supabase', () {
    final payload = DailyReportPayloadBuilder.fromSchoolDraft(
      const SchoolDailyReportDraft(
        centerId: ' center-1 ',
        childId: ' child-1 ',
        reportDate: '2026-09-15',
        breakfast: 'Todo',
        lunch: 'Bastante',
        snack: 'Poco',
        morningPoop: 'No',
        afternoonPoop: 'Si',
        morningSleep: 'Bien',
        morningSleepTime: '12:50',
        afternoonSleep: 'Mal',
        afternoonSleepTime: '',
        schoolNotes: 'Traer ropa',
        homeNotes: '',
        medication: '  ',
        userId: 'user-1',
      ),
    );

    expect(payload['center_id'], 'center-1');
    expect(payload['child_id'], 'child-1');
    expect(payload['breakfast'], 'all');
    expect(payload['lunch'], 'most');
    expect(payload['snack'], 'little');
    expect(payload['morning_bowel_movement'], isFalse);
    expect(payload['afternoon_bowel_movement'], isTrue);
    expect(payload['morning_sleep'], 'good');
    expect(payload['afternoon_sleep'], 'bad');
    expect(payload['afternoon_sleep_time'], isNull);
    expect(payload['home_notes'], isNull);
    expect(payload['medication'], isNull);
    expect(payload['created_by'], 'user-1');
  });

  test('builds a home daily report payload with structured notes', () {
    final payload = DailyReportPayloadBuilder.fromHomeDraft(
      const HomeDailyReportDraft(
        centerId: 'center-1',
        childId: 'child-1',
        reportDate: '2026-09-15',
        sleep: 'Regular',
        breakfast: 'Si',
        bowelMovement: 'No',
        homeNotes: 'Llega un poco cansado',
        medication: '',
        userId: 'guardian-1',
      ),
    );

    expect(payload['home_notes'], contains('Sueno: Regular'));
    expect(payload['home_notes'], contains('Desayuno: Si'));
    expect(payload['home_notes'], contains('Deposicion en casa: No'));
    expect(payload['home_notes'], contains('Llega un poco cansado'));
    expect(payload['medication'], isNull);
    expect(payload['updated_by'], 'guardian-1');
  });
}
