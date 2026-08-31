class EnrollmentDraft {
  const EnrollmentDraft({
    required this.centerId,
    required this.classroomId,
    required this.childFullName,
    required this.birthDate,
    required this.sex,
    required this.allergies,
    required this.medicalNotes,
    required this.notes,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.fatherName,
    required this.fatherEmail,
    required this.fatherPhone,
    required this.motherName,
    required this.motherEmail,
    required this.motherPhone,
    required this.educatorName,
    required this.educatorEmail,
  });

  final String centerId;
  final String classroomId;
  final String childFullName;
  final String birthDate;
  final String sex;
  final String allergies;
  final String medicalNotes;
  final String notes;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String fatherName;
  final String fatherEmail;
  final String fatherPhone;
  final String motherName;
  final String motherEmail;
  final String motherPhone;
  final String educatorName;
  final String educatorEmail;
}

class EnrollmentPayloadBuilder {
  const EnrollmentPayloadBuilder._();

  static Map<String, dynamic> fromDraft(EnrollmentDraft draft) {
    return {
      'centerId': draft.centerId.trim(),
      'classroomId':
          draft.classroomId.trim().isEmpty ? null : draft.classroomId.trim(),
      'child': {
        'fullName': draft.childFullName.trim(),
        'birthDate': draft.birthDate.trim(),
        'sex': draft.sex,
        'allergies': draft.allergies.trim(),
        'medicalNotes': draft.medicalNotes.trim(),
        'notes': draft.notes.trim(),
        'emergencyContactName': draft.emergencyContactName.trim(),
        'emergencyContactPhone': draft.emergencyContactPhone.trim(),
      },
      'guardians': [
        {
          'fullName': draft.fatherName.trim(),
          'email': draft.fatherEmail.trim(),
          'relationship': 'Padre/tutor',
          'phone': draft.fatherPhone.trim(),
          'canPickUp': true,
        },
        if (draft.motherEmail.trim().isNotEmpty)
          {
            'fullName': draft.motherName.trim().isEmpty
                ? 'Madre/tutora'
                : draft.motherName.trim(),
            'email': draft.motherEmail.trim(),
            'relationship': 'Madre/tutora',
            'phone': draft.motherPhone.trim(),
            'canPickUp': true,
          },
      ],
      'educators': [
        if (draft.educatorEmail.trim().isNotEmpty)
          {
            'fullName': draft.educatorName.trim().isEmpty
                ? 'Educadora'
                : draft.educatorName.trim(),
            'email': draft.educatorEmail.trim(),
          },
      ],
    };
  }
}
