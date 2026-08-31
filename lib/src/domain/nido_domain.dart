enum NidoRole { family, educator, admin }

enum MealAmount { all, most, little, none }

enum SleepQuality { good, regular, bad, none }

class AppContextData {
  const AppContextData({
    required this.centerId,
    required this.centerName,
    required this.role,
    required this.children,
    required this.isDemo,
  });

  final String centerId;
  final String centerName;
  final NidoRole role;
  final List<ChildSummary> children;
  final bool isDemo;

  ChildSummary get selectedChild => children.first;
}

class ChildSummary {
  const ChildSummary({
    required this.id,
    required this.fullName,
    required this.classroomName,
  });

  final String id;
  final String fullName;
  final String classroomName;
}

class DailyReportData {
  const DailyReportData({
    required this.childId,
    required this.reportDate,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.morningBowelMovement,
    required this.afternoonBowelMovement,
    required this.morningSleep,
    required this.morningSleepTime,
    required this.afternoonSleep,
    required this.afternoonSleepTime,
    required this.schoolNotes,
    required this.homeNotes,
    required this.medication,
  });

  final String childId;
  final DateTime reportDate;
  final String breakfast;
  final String lunch;
  final String snack;
  final bool morningBowelMovement;
  final bool afternoonBowelMovement;
  final String morningSleep;
  final String? morningSleepTime;
  final String afternoonSleep;
  final String? afternoonSleepTime;
  final String? schoolNotes;
  final String? homeNotes;
  final String? medication;
}

NidoRole roleFromDb(String? value) {
  return switch (value) {
    'admin' => NidoRole.admin,
    'educator' => NidoRole.educator,
    _ => NidoRole.family,
  };
}

String roleToDb(NidoRole role) {
  return switch (role) {
    NidoRole.admin => 'admin',
    NidoRole.educator => 'educator',
    NidoRole.family => 'family',
  };
}

String mealFromDb(String? value) {
  return switch (value) {
    'all' => 'Todo',
    'most' => 'Bastante',
    'little' => 'Poco',
    _ => 'Nada',
  };
}

String mealToDb(String value) {
  return switch (value) {
    'Todo' => 'all',
    'Bastante' => 'most',
    'Poco' => 'little',
    _ => 'none',
  };
}

String sleepFromDb(String? value) {
  return switch (value) {
    'good' => 'Bien',
    'regular' => 'Regular',
    'bad' => 'Mal',
    _ => 'No',
  };
}

String sleepToDb(String value) {
  return switch (value) {
    'Bien' => 'good',
    'Regular' => 'regular',
    'Mal' => 'bad',
    _ => 'none',
  };
}

String? emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obligatorio';
  }
  return null;
}

String? emailField(String? value) {
  final required = requiredField(value);
  if (required != null) return required;
  return optionalEmailField(value);
}

String? optionalEmailField(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed);
  return valid ? null : 'Email no valido';
}

String? birthDateField(String? value) {
  final required = requiredField(value);
  if (required != null) return required;
  final parsed = DateTime.tryParse(value!.trim());
  if (parsed == null) return 'Usa formato AAAA-MM-DD';
  if (parsed.isAfter(DateTime.now())) return 'Fecha futura no valida';
  return null;
}

DailyReportData demoDailyReport(String childId) {
  return DailyReportData(
    childId: childId,
    reportDate: DateTime.now(),
    breakfast: 'Todo',
    lunch: 'Bastante',
    snack: 'Poco',
    morningBowelMovement: false,
    afternoonBowelMovement: true,
    morningSleep: 'Bien',
    morningSleepTime: '12:50',
    afternoonSleep: 'Bien',
    afternoonSleepTime: '14:50',
    schoolNotes: 'Traer suero fisiologico y cochecito.',
    homeNotes: 'Ha dormido regular. Esta manana no ha querido leche.',
    medication: 'Sin medicacion pautada hoy.',
  );
}
