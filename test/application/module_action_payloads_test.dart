import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/src/application/module_action_payloads.dart';

void main() {
  test('builds message payload for a child conversation', () {
    final payload = ModuleActionPayloadBuilder.fromMessage(
      const MessageDraft(
        centerId: ' center-1 ',
        childId: ' child-1 ',
        senderId: 'user-1',
        category: 'Salud',
        body: ' Tiene tos ',
      ),
    );

    expect(payload['center_id'], 'center-1');
    expect(payload['child_id'], 'child-1');
    expect(payload['sender_id'], 'user-1');
    expect(payload['category'], 'health');
    expect(payload['body'], 'Tiene tos');
  });

  test('builds attendance payload with optional notes', () {
    final payload = ModuleActionPayloadBuilder.fromAttendance(
      const AttendanceEventDraft(
        centerId: 'center-1',
        childId: 'child-1',
        actorId: 'user-1',
        eventType: 'check_in',
        notes: '',
      ),
    );

    expect(payload['event_type'], 'check_in');
    expect(payload['notes'], isNull);
  });

  test('builds media payload waiting for storage upload', () {
    final payload = ModuleActionPayloadBuilder.fromMediaAsset(
      const MediaAssetDraft(
        centerId: 'center-1',
        childId: 'child-1',
        uploadedBy: 'user-1',
        title: ' Taller pintura ',
        activity: ' Pintura ',
        takenOn: '2026-09-08',
      ),
    );

    expect(payload['kind'], 'photo');
    expect(payload['title'], 'Taller pintura');
    expect(payload['activity'], 'Pintura');
    expect(payload['taken_on'], '2026-09-08');
    expect(payload['storage_path'], startsWith('pending-upload/center-1/'));
  });
}
