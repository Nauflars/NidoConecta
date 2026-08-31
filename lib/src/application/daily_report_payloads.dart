import '../domain/nido_domain.dart';

class SchoolDailyReportDraft {
  const SchoolDailyReportDraft({
    required this.centerId,
    required this.childId,
    required this.reportDate,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.morningPoop,
    required this.afternoonPoop,
    required this.morningSleep,
    required this.morningSleepTime,
    required this.afternoonSleep,
    required this.afternoonSleepTime,
    required this.schoolNotes,
    required this.homeNotes,
    required this.medication,
    required this.userId,
  });

  final String centerId;
  final String childId;
  final String reportDate;
  final String breakfast;
  final String lunch;
  final String snack;
  final String morningPoop;
  final String afternoonPoop;
  final String morningSleep;
  final String morningSleepTime;
  final String afternoonSleep;
  final String afternoonSleepTime;
  final String schoolNotes;
  final String homeNotes;
  final String medication;
  final String? userId;
}

class HomeDailyReportDraft {
  const HomeDailyReportDraft({
    required this.centerId,
    required this.childId,
    required this.reportDate,
    required this.sleep,
    required this.breakfast,
    required this.bowelMovement,
    required this.homeNotes,
    required this.medication,
    required this.userId,
  });

  final String centerId;
  final String childId;
  final String reportDate;
  final String sleep;
  final String breakfast;
  final String bowelMovement;
  final String homeNotes;
  final String medication;
  final String? userId;
}

class DailyReportPayloadBuilder {
  const DailyReportPayloadBuilder._();

  static Map<String, dynamic> fromSchoolDraft(SchoolDailyReportDraft draft) {
    return {
      'center_id': draft.centerId.trim(),
      'child_id': draft.childId.trim(),
      'report_date': draft.reportDate.trim(),
      'breakfast': mealToDb(draft.breakfast),
      'lunch': mealToDb(draft.lunch),
      'snack': mealToDb(draft.snack),
      'morning_bowel_movement': draft.morningPoop == 'Si',
      'afternoon_bowel_movement': draft.afternoonPoop == 'Si',
      'morning_sleep': sleepToDb(draft.morningSleep),
      'morning_sleep_time': emptyToNull(draft.morningSleepTime),
      'afternoon_sleep': sleepToDb(draft.afternoonSleep),
      'afternoon_sleep_time': emptyToNull(draft.afternoonSleepTime),
      'school_notes': emptyToNull(draft.schoolNotes),
      'home_notes': emptyToNull(draft.homeNotes),
      'medication': emptyToNull(draft.medication),
      'created_by': draft.userId,
      'updated_by': draft.userId,
    };
  }

  static Map<String, dynamic> fromHomeDraft(HomeDailyReportDraft draft) {
    final notes = [
      'Sueno: ${draft.sleep}',
      'Desayuno: ${draft.breakfast}',
      'Deposicion en casa: ${draft.bowelMovement}',
      if (draft.homeNotes.trim().isNotEmpty) draft.homeNotes.trim(),
    ].join('\n');

    return {
      'center_id': draft.centerId.trim(),
      'child_id': draft.childId.trim(),
      'report_date': draft.reportDate.trim(),
      'home_notes': notes,
      'medication': emptyToNull(draft.medication),
      'created_by': draft.userId,
      'updated_by': draft.userId,
    };
  }
}
