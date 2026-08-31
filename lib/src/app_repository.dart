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

  Future<AdminDashboardData> loadAdminDashboard(String centerId) async {
    final client = _client;
    if (client == null) {
      return const AdminDashboardData(
        childrenCount: 1,
        educatorsCount: 1,
        todayReportsCount: 1,
        todayAttendanceCount: 1,
        messagesCount: 2,
        mediaCount: 4,
      );
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final results = await Future.wait<int>([
      _count(client.from('children').select('id'), centerId: centerId),
      _count(
        client.from('center_memberships').select('user_id'),
        centerId: centerId,
        role: 'educator',
      ),
      _count(
        client.from('daily_reports').select('id'),
        centerId: centerId,
        reportDate: today,
      ),
      _count(
        client.from('attendance_events').select('id'),
        centerId: centerId,
        todayColumn: 'occurred_at',
      ),
      _count(client.from('messages').select('id'), centerId: centerId),
      _count(client.from('media_assets').select('id'), centerId: centerId),
    ]);

    return AdminDashboardData(
      childrenCount: results[0],
      educatorsCount: results[1],
      todayReportsCount: results[2],
      todayAttendanceCount: results[3],
      messagesCount: results[4],
      mediaCount: results[5],
    );
  }

  Future<List<EducatorChildStatus>> loadEducatorStatuses(
    AppContextData context,
  ) async {
    final client = _client;
    if (client == null) {
      return [
        for (final child in context.children)
          EducatorChildStatus(
            child: child,
            food: 'Bastante',
            sleep: '12:45-14:15',
            diaper: '1',
            note: 'Demo',
          ),
      ];
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final reports = await client
        .from('daily_reports')
        .select('child_id, lunch, afternoon_sleep_time, school_notes')
        .eq('center_id', context.centerId)
        .eq('report_date', today);
    final byChild = {
      for (final row in reports) row['child_id'] as String: row,
    };

    return [
      for (final child in context.children)
        EducatorChildStatus(
          child: child,
          food: mealFromDb(byChild[child.id]?['lunch'] as String?),
          sleep: byChild[child.id]?['afternoon_sleep_time'] as String? ?? '-',
          diaper: '-',
          note: byChild[child.id]?['school_notes'] as String? ?? '',
        ),
    ];
  }

  Future<List<StaffMemberData>> loadStaffMembers(String centerId) async {
    final client = _client;
    if (client == null) {
      return const [
        StaffMemberData(
          fullName: 'Laura Marti',
          role: 'Educadora',
          phone: null,
        ),
        StaffMemberData(
          fullName: 'Marta Soler',
          role: 'Educadora',
          phone: null,
        ),
      ];
    }

    final rows = await client
        .from('center_memberships')
        .select('role, profiles(full_name, phone)')
        .eq('center_id', centerId)
        .order('role');

    return rows
        .where((row) => row['role'] == 'educator' || row['role'] == 'admin')
        .map<StaffMemberData>((row) {
      final profile = row['profiles'] as Map<String, dynamic>?;
      return StaffMemberData(
        fullName: profile?['full_name'] as String? ?? 'Usuario sin perfil',
        role: row['role'] == 'admin' ? 'Direccion' : 'Educadora',
        phone: profile?['phone'] as String?,
      );
    }).toList();
  }

  Future<void> publishAnnouncement(Map<String, dynamic> payload) async {
    final client = _client;
    if (client == null) return;
    await client.from('announcements').insert(payload);
  }

  Future<void> createCalendarEvent(Map<String, dynamic> payload) async {
    final client = _client;
    if (client == null) return;
    await client.from('calendar_events').insert(payload);
  }

  Future<void> createMessage(Map<String, dynamic> payload) async {
    final client = _client;
    if (client == null) return;
    await client.from('messages').insert(payload);
  }

  Future<void> createAttendanceEvent(Map<String, dynamic> payload) async {
    final client = _client;
    if (client == null) return;
    await client.from('attendance_events').insert(payload);
  }

  Future<void> createMediaAsset(Map<String, dynamic> payload) async {
    final client = _client;
    if (client == null) return;
    await client.from('media_assets').insert(payload);
  }

  Future<List<MetricItemData>> loadModuleItems(
    String centerId,
    ModuleKind kind,
  ) async {
    final client = _client;
    if (client == null) return const [];

    return switch (kind) {
      ModuleKind.calendar => _loadCalendarItems(client, centerId),
      ModuleKind.menu => _loadMenuItems(client, centerId),
      ModuleKind.messages => _loadMessageItems(client, centerId),
      ModuleKind.media => _loadMediaItems(client, centerId),
      ModuleKind.children => _loadChildrenItems(client, centerId),
      ModuleKind.attendance => _loadAttendanceItems(client, centerId),
      ModuleKind.announcements => _loadAnnouncementItems(client, centerId),
      ModuleKind.pickups => _loadPickupItems(client, centerId),
      ModuleKind.staff => _loadStaffItems(client, centerId),
    };
  }

  Future<List<MetricItemData>> _loadCalendarItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('calendar_events')
        .select('title, starts_on, is_closed_day')
        .eq('center_id', centerId)
        .order('starts_on')
        .limit(12);
    return rows
        .map<MetricItemData>((row) => MetricItemData(
              row['title'] as String,
              '${row['starts_on']}${row['is_closed_day'] == true ? ' - cerrado' : ''}',
            ))
        .toList();
  }

  Future<List<MetricItemData>> _loadMenuItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('menus')
        .select('menu_date, first_course, second_course, dessert')
        .eq('center_id', centerId)
        .order('menu_date')
        .limit(10);
    return rows
        .map<MetricItemData>((row) => MetricItemData(
              row['menu_date'] as String,
              [
                row['first_course'],
                row['second_course'],
                row['dessert'],
              ].whereType<String>().join(' - '),
            ))
        .toList();
  }

  Future<List<MetricItemData>> _loadMessageItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('messages')
        .select('category, body')
        .eq('center_id', centerId)
        .order('created_at', ascending: false)
        .limit(10);
    return rows
        .map<MetricItemData>((row) => MetricItemData(
              row['category'] as String? ?? 'Mensaje',
              row['body'] as String? ?? '',
            ))
        .toList();
  }

  Future<List<MetricItemData>> _loadMediaItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('media_assets')
        .select('title, activity, taken_on, created_at')
        .eq('center_id', centerId)
        .order('created_at', ascending: false)
        .limit(10);
    return rows
        .map<MetricItemData>((row) => MetricItemData(
              row['title'] as String? ?? 'Archivo',
              '${row['activity'] ?? 'Actividad'} - ${row['taken_on'] ?? ''}',
            ))
        .toList();
  }

  Future<List<MetricItemData>> _loadChildrenItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('children')
        .select('full_name, classrooms(name)')
        .eq('center_id', centerId)
        .order('full_name')
        .limit(30);
    return rows.map<MetricItemData>((row) {
      final classroom = row['classrooms'] as Map<String, dynamic>?;
      return MetricItemData(
        row['full_name'] as String,
        classroom?['name'] as String? ?? 'Sin aula',
      );
    }).toList();
  }

  Future<List<MetricItemData>> _loadAttendanceItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('attendance_events')
        .select('event_type, occurred_at, children(full_name)')
        .eq('center_id', centerId)
        .order('occurred_at', ascending: false)
        .limit(10);
    return rows.map<MetricItemData>((row) {
      final child = row['children'] as Map<String, dynamic>?;
      return MetricItemData(
        child?['full_name'] as String? ?? 'Alumno',
        '${row['event_type']} - ${row['occurred_at']}',
      );
    }).toList();
  }

  Future<List<MetricItemData>> _loadAnnouncementItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final rows = await client
        .from('announcements')
        .select('title, body')
        .eq('center_id', centerId)
        .order('created_at', ascending: false)
        .limit(10);
    return rows
        .map<MetricItemData>((row) => MetricItemData(
              row['title'] as String,
              row['body'] as String,
            ))
        .toList();
  }

  Future<List<MetricItemData>> _loadPickupItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final children = await _loadCenterChildren(client, centerId);
    if (children.isEmpty) return const [];
    final rows = await client
        .from('authorized_pickups')
        .select('full_name, relationship')
        .eq('child_id', children.first.id)
        .limit(10);
    return rows
        .map<MetricItemData>((row) => MetricItemData(
              row['full_name'] as String,
              row['relationship'] as String,
            ))
        .toList();
  }

  Future<List<MetricItemData>> _loadStaffItems(
    SupabaseClient client,
    String centerId,
  ) async {
    final staff = await loadStaffMembers(centerId);
    return staff
        .map((member) => MetricItemData(
              member.fullName,
              [member.role, member.phone].whereType<String>().join(' - '),
            ))
        .toList();
  }

  Future<int> _count(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query, {
    required String centerId,
    String? role,
    String? reportDate,
    String? todayColumn,
  }) async {
    var filtered = query.eq('center_id', centerId);
    if (role != null) filtered = filtered.eq('role', role);
    if (reportDate != null) filtered = filtered.eq('report_date', reportDate);
    if (todayColumn != null) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final start = DateTime.now().toIso8601String().substring(0, 10);
      final end = tomorrow.toIso8601String().substring(0, 10);
      filtered = filtered.gte(todayColumn, start).lt(todayColumn, end);
    }
    final rows = await filtered;
    return rows.length;
  }
}
