import 'package:flutter_test/flutter_test.dart';
import 'package:nidoconecta/src/application/enrollment_payload.dart';

void main() {
  test('builds enrollment payload with father, mother and educator invitations',
      () {
    final payload = EnrollmentPayloadBuilder.fromDraft(
      const EnrollmentDraft(
        centerId: ' center-1 ',
        classroomId: ' classroom-1 ',
        childFullName: ' Mateo Ruiz ',
        birthDate: '2024-02-09',
        sex: 'boy',
        allergies: 'Lactosa',
        medicalNotes: 'Inhalador autorizado',
        notes: 'Adaptacion progresiva',
        emergencyContactName: 'Tia Ana',
        emergencyContactPhone: '600111222',
        fatherName: 'Padre',
        fatherEmail: 'padre@example.com',
        fatherPhone: '600000001',
        motherName: '',
        motherEmail: 'madre@example.com',
        motherPhone: '600000002',
        educatorName: '',
        educatorEmail: 'educadora@example.com',
      ),
    );

    expect(payload['centerId'], 'center-1');
    expect(payload['classroomId'], 'classroom-1');
    expect(payload['child']['fullName'], 'Mateo Ruiz');
    expect(payload['child']['sex'], 'boy');
    expect(payload['guardians'], hasLength(2));
    expect(payload['guardians'][0]['relationship'], 'Padre/tutor');
    expect(payload['guardians'][1]['fullName'], 'Madre/tutora');
    expect(payload['educators'], hasLength(1));
    expect(payload['educators'][0]['fullName'], 'Educadora');
  });

  test('omits optional classroom, mother and educator when empty', () {
    final payload = EnrollmentPayloadBuilder.fromDraft(
      const EnrollmentDraft(
        centerId: 'center-1',
        classroomId: '',
        childFullName: 'Mateo Ruiz',
        birthDate: '2024-02-09',
        sex: 'boy',
        allergies: '',
        medicalNotes: '',
        notes: '',
        emergencyContactName: '',
        emergencyContactPhone: '',
        fatherName: 'Padre',
        fatherEmail: 'padre@example.com',
        fatherPhone: '',
        motherName: '',
        motherEmail: '',
        motherPhone: '',
        educatorName: '',
        educatorEmail: '',
      ),
    );

    expect(payload['classroomId'], isNull);
    expect(payload['guardians'], hasLength(1));
    expect(payload['educators'], isEmpty);
  });
}
