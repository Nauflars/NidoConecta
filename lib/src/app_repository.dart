import 'package:supabase_flutter/supabase_flutter.dart';

enum NidoRole { family, educator, admin }

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

class AppRepository {
  AppRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static AppContextData demoContext() {
    return const AppContextData(
      centerId: 'demo-center',
      centerName: 'Centro piloto',
      role: NidoRole.family,
      isDemo: true,
      children: [
        ChildSummary(
          id: 'demo-child-mateo',
          fullName: 'Mateo',
          classroomName: 'Clase Mariposas',
        ),
      ],
    );
  }

  Future<AppContextData> loadContext() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return demoContext();

    final membership = await client
        .from('center_memberships')
        .select('center_id, role, centers(name)')
        .eq('user_id', user.id)
        .limit(1)
        .maybeSingle();

    if (membership == null) return demoContext();

    final centerId = membership['center_id'] as String;
    final role = roleFromDb(membership['role'] as String?);
    final center = membership['centers'] as Map<String, dynamic>?;

    final children = role == NidoRole.family
        ? await _loadFamilyChildren(client)
        : await _loadCenterChildren(client, centerId);

    return AppContextData(
      centerId: centerId,
      centerName: center?['name'] as String? ?? 'Centro',
      role: role,
      children: children.isEmpty ? demoContext().children : children,
      isDemo: false,
    );
  }

  Future<List<ChildSummary>> _loadFamilyChildren(SupabaseClient client) async {
    final rows = await client
        .from('child_guardians')
        .select('children(id, full_name, classrooms(name))');

    return rows
        .map<ChildSummary?>((row) {
          final child = row['children'] as Map<String, dynamic>?;
          if (child == null) return null;
          final classroom = child['classrooms'] as Map<String, dynamic>?;
          return ChildSummary(
            id: child['id'] as String,
            fullName: child['full_name'] as String,
            classroomName: classroom?['name'] as String? ?? 'Sin aula',
          );
        })
        .whereType<ChildSummary>()
        .toList();
  }

  Future<List<ChildSummary>> _loadCenterChildren(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('children')
        .select('id, full_name, classrooms(name)')
        .eq('center_id', centerId)
        .order('full_name');

    return rows.map<ChildSummary>((row) {
      final classroom = row['classrooms'] as Map<String, dynamic>?;
      return ChildSummary(
        id: row['id'] as String,
        fullName: row['full_name'] as String,
        classroomName: classroom?['name'] as String? ?? 'Sin aula',
      );
    }).toList();
  }

  Future<DailyReportData?> loadTodayReport(String childId) async {
    final client = _client;
    if (client == null) return null;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final row = await client
        .from('daily_reports')
        .select()
        .eq('child_id', childId)
        .eq('report_date', today)
        .maybeSingle();

    if (row == null) return null;

    return DailyReportData(
      childId: childId,
      reportDate: DateTime.parse(row['report_date'] as String),
      breakfast: mealFromDb(row['breakfast'] as String?),
      lunch: mealFromDb(row['lunch'] as String?),
      snack: mealFromDb(row['snack'] as String?),
      morningBowelMovement: row['morning_bowel_movement'] as bool? ?? false,
      afternoonBowelMovement: row['afternoon_bowel_movement'] as bool? ?? false,
      morningSleep: sleepFromDb(row['morning_sleep'] as String?),
      morningSleepTime: row['morning_sleep_time'] as String?,
      afternoonSleep: sleepFromDb(row['afternoon_sleep'] as String?),
      afternoonSleepTime: row['afternoon_sleep_time'] as String?,
      schoolNotes: row['school_notes'] as String?,
      homeNotes: row['home_notes'] as String?,
      medication: row['medication'] as String?,
    );
  }
}

NidoRole roleFromDb(String? value) {
  return switch (value) {
    'admin' => NidoRole.admin,
    'educator' => NidoRole.educator,
    _ => NidoRole.family,
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

String sleepFromDb(String? value) {
  return switch (value) {
    'good' => 'Bien',
    'bad' => 'Mal',
    _ => 'No',
  };
}
