import 'package:supabase_flutter/supabase_flutter.dart';

import 'application/demo_context.dart';
import 'domain/nido_domain.dart';

class AppRepository {
  AppRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  static AppContextData demoContext() {
    return DemoContextFactory.create();
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
