import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/src/application/admin_content_payloads.dart';

void main() {
  test('builds announcement payload with trimmed content', () {
    final payload = AdminContentPayloadBuilder.fromAnnouncement(
      const AnnouncementDraft(
        centerId: ' center-1 ',
        title: ' Salida ',
        body: ' Traer mochila ',
        authorId: 'user-1',
      ),
    );

    expect(payload['center_id'], 'center-1');
    expect(payload['title'], 'Salida');
    expect(payload['body'], 'Traer mochila');
    expect(payload['created_by'], 'user-1');
    expect(payload['published_at'], isA<String>());
  });

  test('builds calendar payload with optional end date', () {
    final payload = AdminContentPayloadBuilder.fromCalendarEvent(
      const CalendarEventDraft(
        centerId: ' center-1 ',
        title: ' Fiesta ',
        startsOn: '2026-09-15',
        endsOn: ' ',
        isClosedDay: true,
      ),
    );

    expect(payload, {
      'center_id': 'center-1',
      'title': 'Fiesta',
      'starts_on': '2026-09-15',
      'ends_on': null,
      'is_closed_day': true,
    });
  });
}
