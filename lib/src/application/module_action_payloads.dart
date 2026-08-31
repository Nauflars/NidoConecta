class MessageDraft {
  const MessageDraft({
    required this.centerId,
    required this.childId,
    required this.senderId,
    required this.category,
    required this.body,
  });

  final String centerId;
  final String? childId;
  final String? senderId;
  final String category;
  final String body;
}

class AttendanceEventDraft {
  const AttendanceEventDraft({
    required this.centerId,
    required this.childId,
    required this.actorId,
    required this.eventType,
    required this.notes,
  });

  final String centerId;
  final String childId;
  final String? actorId;
  final String eventType;
  final String notes;
}

class MediaAssetDraft {
  const MediaAssetDraft({
    required this.centerId,
    required this.childId,
    required this.uploadedBy,
    required this.title,
    required this.activity,
    required this.takenOn,
  });

  final String centerId;
  final String? childId;
  final String? uploadedBy;
  final String title;
  final String activity;
  final String takenOn;
}

class ModuleActionPayloadBuilder {
  const ModuleActionPayloadBuilder._();

  static Map<String, dynamic> fromMessage(MessageDraft draft) {
    return {
      'center_id': draft.centerId.trim(),
      'child_id': _emptyToNull(draft.childId),
      'sender_id': draft.senderId,
      'category': _messageCategoryToDb(draft.category),
      'body': draft.body.trim(),
    };
  }

  static Map<String, dynamic> fromAttendance(AttendanceEventDraft draft) {
    return {
      'center_id': draft.centerId.trim(),
      'child_id': draft.childId.trim(),
      'event_type': draft.eventType,
      'actor_id': draft.actorId,
      'notes': _emptyToNull(draft.notes),
    };
  }

  static Map<String, dynamic> fromMediaAsset(MediaAssetDraft draft) {
    final takenOn = draft.takenOn.trim();
    final title = draft.title.trim();
    final stableTitle = title.isEmpty ? 'Foto de aula' : title;
    final storageName = stableTitle.toLowerCase().replaceAll(' ', '-');

    return {
      'center_id': draft.centerId.trim(),
      'child_id': _emptyToNull(draft.childId),
      'kind': 'photo',
      'storage_path':
          'pending-upload/${draft.centerId.trim()}/$storageName-${DateTime.now().millisecondsSinceEpoch}.jpg',
      'title': stableTitle,
      'activity': _emptyToNull(draft.activity),
      'taken_on': takenOn,
      'uploaded_by': draft.uploadedBy,
    };
  }

  static String _messageCategoryToDb(String label) {
    return switch (label) {
      'Ausencia' => 'absence',
      'Comedor' => 'meal',
      'Horario' => 'schedule',
      'Administracion' => 'administration',
      'Educadora' => 'educator',
      'Salud' => 'health',
      _ => 'other',
    };
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
