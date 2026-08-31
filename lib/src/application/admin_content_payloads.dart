class AnnouncementDraft {
  const AnnouncementDraft({
    required this.centerId,
    required this.title,
    required this.body,
    required this.authorId,
  });

  final String centerId;
  final String title;
  final String body;
  final String? authorId;
}

class CalendarEventDraft {
  const CalendarEventDraft({
    required this.centerId,
    required this.title,
    required this.startsOn,
    required this.endsOn,
    required this.isClosedDay,
  });

  final String centerId;
  final String title;
  final String startsOn;
  final String endsOn;
  final bool isClosedDay;
}

class AdminContentPayloadBuilder {
  const AdminContentPayloadBuilder._();

  static Map<String, dynamic> fromAnnouncement(AnnouncementDraft draft) {
    return {
      'center_id': draft.centerId.trim(),
      'title': draft.title.trim(),
      'body': draft.body.trim(),
      'published_at': DateTime.now().toUtc().toIso8601String(),
      'created_by': draft.authorId,
    };
  }

  static Map<String, dynamic> fromCalendarEvent(CalendarEventDraft draft) {
    final endsOn = draft.endsOn.trim();
    return {
      'center_id': draft.centerId.trim(),
      'title': draft.title.trim(),
      'starts_on': draft.startsOn.trim(),
      'ends_on': endsOn.isEmpty ? null : endsOn,
      'is_closed_day': draft.isClosedDay,
    };
  }
}
