import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool isSupabaseConfigured = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
    isSupabaseConfigured = true;
  }

  runApp(const NidoConectaApp());
}

class NidoConectaApp extends StatelessWidget {
  const NidoConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1F7A68);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NidoConecta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5EF),
        useMaterial3: true,
      ),
      home: isSupabaseConfigured ? const AuthGate() : const HomeShell(),
    );
  }
}

enum AppRole { family, educator, admin }

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) return const LoginScreen();
        return const HomeShell();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NidoConecta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            const HeaderBlock(
              title: 'Entrar',
              subtitle: 'Cuenta de acceso',
              metric: 'Usa el email recibido por invitacion',
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _email,
              label: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: emailField,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contrasena',
                prefixIcon: Icon(Icons.password_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _signIn,
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_outlined),
                label: Text(_loading ? 'Entrando' : 'Entrar'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : _resetPassword,
              child: const Text('Cambiar o recuperar contrasena'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (optionalEmailField(email) != null || email.isEmpty) {
      _showError('Escribe tu email primero');
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email enviado')),
      );
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  AppRole _role = AppRole.family;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NidoConecta'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusPill(
              label: isSupabaseConfigured ? 'Supabase listo' : 'Modo demo',
              icon: isSupabaseConfigured ? Icons.cloud_done : Icons.cloud_off,
            ),
          ),
          if (isSupabaseConfigured)
            IconButton(
              tooltip: 'Salir',
              onPressed: () => Supabase.instance.client.auth.signOut(),
              icon: const Icon(Icons.logout_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            RoleSelector(selected: _role, onChanged: _setRole),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: switch (_role) {
                AppRole.family => const FamilyTodayView(),
                AppRole.educator => const EducatorClassView(),
                AppRole.admin => const AdminDashboardView(),
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setRole(AppRole role) {
    setState(() => _role = role);
  }
}

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppRole selected;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppRole>(
      segments: const [
        ButtonSegment(
          value: AppRole.family,
          label: Text('Familia'),
          icon: Icon(Icons.home_outlined),
        ),
        ButtonSegment(
          value: AppRole.educator,
          label: Text('Educadora'),
          icon: Icon(Icons.groups_outlined),
        ),
        ButtonSegment(
          value: AppRole.admin,
          label: Text('Dirección'),
          icon: Icon(Icons.dashboard_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onChanged(value.single),
      showSelectedIcon: false,
    );
  }
}

class FamilyTodayView extends StatelessWidget {
  const FamilyTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('family'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeaderBlock(
          title: 'Mateo',
          subtitle: 'Agenda diaria',
          metric: 'Martes 15 de septiembre · entrada 08:37',
          icon: Icons.child_care,
        ),
        const SizedBox(height: 12),
        const DailyNotebookCard(),
        const SizedBox(height: 12),
        const NoteCard(
          title: 'Observaciones de la escuela',
          text: 'Traer suero fisiologico y cochecito.',
        ),
        const SizedBox(height: 12),
        const NoteCard(
          title: 'Observaciones de casa',
          text: 'Ha dormido regular. Esta manana no ha querido leche.',
        ),
        const SizedBox(height: 12),
        const NoteCard(
          title: 'Medicacion',
          text: 'Sin medicacion pautada hoy.',
        ),
        const SizedBox(height: 16),
        PrimaryActionButton(
          label: 'Enviar mensaje',
          icon: Icons.chat_bubble_outline,
          onPressed: () => openModule(context, const MessagesScreen()),
        ),
        const SizedBox(height: 16),
        const ModuleGrid(
          modules: [
            AppModule('Calendario', Icons.event_outlined, CalendarScreen()),
            AppModule('Menu', Icons.restaurant_menu_outlined, MenuScreen()),
            AppModule('Fotos', Icons.photo_library_outlined, MediaScreen()),
            AppModule(
              'Autorizados',
              Icons.verified_user_outlined,
              AuthorizedPickupsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

class DailyNotebookCard extends StatelessWidget {
  const DailyNotebookCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Ha comido'),
          FoodStatusRow(meal: 'Desayuno', amount: 'Todo'),
          FoodStatusRow(meal: 'Comida', amount: 'Bastante'),
          FoodStatusRow(meal: 'Merienda', amount: 'Poco'),
          Divider(height: 24),
          SectionTitle('Deposiciones'),
          DayPartStatus(label: 'Manana', value: 'No'),
          DayPartStatus(label: 'Tarde', value: 'Si'),
          Divider(height: 24),
          SectionTitle('Ha dormido'),
          SleepStatus(label: 'Manana', quality: 'Bien', time: '12:50'),
          SleepStatus(label: 'Tarde', quality: 'Bien', time: '14:50'),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class FoodStatusRow extends StatelessWidget {
  const FoodStatusRow({super.key, required this.meal, required this.amount});

  final String meal;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(meal)),
          StatusDot(label: 'Todo', selected: amount == 'Todo'),
          StatusDot(label: 'Bastante', selected: amount == 'Bastante'),
          StatusDot(label: 'Poco', selected: amount == 'Poco'),
          StatusDot(label: 'Nada', selected: amount == 'Nada'),
        ],
      ),
    );
  }
}

class DayPartStatus extends StatelessWidget {
  const DayPartStatus({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          StatusDot(label: 'Si', selected: value == 'Si'),
          StatusDot(label: 'No', selected: value == 'No'),
        ],
      ),
    );
  }
}

class SleepStatus extends StatelessWidget {
  const SleepStatus({
    super.key,
    required this.label,
    required this.quality,
    required this.time,
  });

  final String label;
  final String quality;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          StatusDot(label: 'Bien', selected: quality == 'Bien'),
          StatusDot(label: 'Mal', selected: quality == 'Mal'),
          const SizedBox(width: 8),
          SizedBox(width: 54, child: Text(time, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: colors.outlineVariant),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 48,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyGrid extends StatelessWidget {
  const DailyGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      MetricItem('Comida', 'Muy bien', Icons.restaurant_outlined),
      MetricItem('Siesta', '12:47 - 14:09', Icons.bedtime_outlined),
      MetricItem('Pañales', '3 cambios', Icons.clean_hands_outlined),
      MetricItem('Fotos', '4 nuevas', Icons.photo_library_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 620 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: columns == 4 ? 1.45 : 1.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final item in items)
              InfoTile(
                title: item.title,
                value: item.value,
                icon: item.icon,
              ),
          ],
        );
      },
    );
  }
}

class EducatorClassView extends StatelessWidget {
  const EducatorClassView({super.key});

  @override
  Widget build(BuildContext context) {
    const children = [
      ChildRow('Mateo', 'Todo', '1h 22min', '3', ''),
      ChildRow('Lucas', 'Bastante', 'Activa', '2', 'Nota'),
      ChildRow('Ana', 'Todo', '50min', '-', ''),
      ChildRow('Leo', 'Poco', '1h 05min', '2', 'Revisar'),
    ];

    return Column(
      key: const ValueKey('educator'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeaderBlock(
          title: 'Clase Mariposas',
          subtitle: '13 niños',
          metric: '57 acciones registradas hoy',
          icon: Icons.groups,
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            QuickAction(label: 'Entrada', icon: Icons.qr_code_scanner),
            QuickAction(label: 'Comida', icon: Icons.restaurant),
            QuickAction(label: 'Siesta', icon: Icons.bedtime),
            QuickAction(label: 'Pañal', icon: Icons.checklist),
            QuickAction(label: 'Fotos', icon: Icons.add_a_photo),
            QuickAction(label: 'Voz', icon: Icons.mic),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryActionButton(
          label: 'Registrar agenda de Mateo',
          icon: Icons.edit_note_outlined,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DailyReportFormScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const ModuleGrid(
          modules: [
            AppModule('Asistencia', Icons.qr_code_scanner, AttendanceScreen()),
            AppModule('Mensajes', Icons.forum_outlined, MessagesScreen()),
            AppModule('Fotos', Icons.add_a_photo_outlined, MediaScreen()),
            AppModule('Calendario', Icons.event_outlined, CalendarScreen()),
          ],
        ),
        const SizedBox(height: 16),
        DataTable(
          headingRowHeight: 42,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columns: const [
            DataColumn(label: Text('Niño')),
            DataColumn(label: Text('Comida')),
            DataColumn(label: Text('Siesta')),
            DataColumn(label: Text('Pañal')),
            DataColumn(label: Text('Nota')),
          ],
          rows: [
            for (final child in children)
              DataRow(
                cells: [
                  DataCell(Text(child.name)),
                  DataCell(Text(child.food)),
                  DataCell(Text(child.sleep)),
                  DataCell(Text(child.diaper)),
                  DataCell(Text(child.note)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      MetricItem('Presentes', '57 / 64', Icons.how_to_reg_outlined),
      MetricItem('Educadoras', '8', Icons.badge_outlined),
      MetricItem('Comedor', '46', Icons.restaurant_menu_outlined),
      MetricItem('Incidencias', '3', Icons.warning_amber_outlined),
      MetricItem('Mensajes', '7', Icons.mark_unread_chat_alt_outlined),
      MetricItem('Fotos', '42', Icons.collections_outlined),
    ];

    return Column(
      key: const ValueKey('admin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeaderBlock(
          title: 'Centro piloto',
          subtitle: 'Panel de dirección',
          metric: 'Curso 2026-2027',
          icon: Icons.apartment,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 740 ? 3 : 2;

            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: columns == 3 ? 1.8 : 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final item in items)
                  InfoTile(
                    title: item.title,
                    value: item.value,
                    icon: item.icon,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        PrimaryActionButton(
          label: 'Nueva alta',
          icon: Icons.person_add_alt_1_outlined,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EnrollmentFormScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const ModuleGrid(
          modules: [
            AppModule('Alumnos', Icons.child_care_outlined, ChildrenScreen()),
            AppModule(
                'Comunicados', Icons.campaign_outlined, AnnouncementsScreen()),
            AppModule('Calendario', Icons.event_outlined, CalendarScreen()),
            AppModule('Menu', Icons.restaurant_menu_outlined, MenuScreen()),
            AppModule('Fotos', Icons.collections_outlined, MediaScreen()),
            AppModule('Mensajes', Icons.forum_outlined, MessagesScreen()),
          ],
        ),
      ],
    );
  }
}

void openModule(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class AppModule {
  const AppModule(this.title, this.icon, this.screen);

  final String title;
  final IconData icon;
  final Widget screen;
}

class ModuleGrid extends StatelessWidget {
  const ModuleGrid({super.key, required this.modules});

  final List<AppModule> modules;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 720 ? 3 : 2;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: columns == 3 ? 2.5 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final module in modules)
              OutlinedButton.icon(
                onPressed: () => openModule(context, module.screen),
                icon: Icon(module.icon),
                label: Text(module.title, overflow: TextOverflow.ellipsis),
              ),
          ],
        );
      },
    );
  }
}

class SimpleModuleScreen extends StatelessWidget {
  const SimpleModuleScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
    this.actionLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<MetricItem> items;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            HeaderBlock(
              title: title,
              subtitle: subtitle,
              metric: 'Centro piloto',
              icon: icon,
            ),
            const SizedBox(height: 12),
            for (final item in items) ...[
              InfoTile(title: item.title, value: item.value, icon: item.icon),
              const SizedBox(height: 10),
            ],
            if (actionLabel != null)
              PrimaryActionButton(label: actionLabel!, icon: Icons.add),
          ],
        ),
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Calendario',
      subtitle: 'Eventos y festivos',
      icon: Icons.event_outlined,
      actionLabel: 'Nuevo evento',
      items: [
        MetricItem('Viernes', 'Salida mensual', Icons.directions_bus_outlined),
        MetricItem('Lunes', 'Centro cerrado', Icons.event_busy_outlined),
      ],
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Menu',
      subtitle: 'Comedor mensual',
      icon: Icons.restaurant_menu_outlined,
      actionLabel: 'Importar menu',
      items: [
        MetricItem('Hoy', 'Macarrones · merluza · fruta', Icons.restaurant),
        MetricItem('Alergias', '2 dietas especiales', Icons.health_and_safety),
      ],
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Mensajes',
      subtitle: 'Conversaciones por categoria',
      icon: Icons.forum_outlined,
      actionLabel: 'Nuevo mensaje',
      items: [
        MetricItem('Salud', 'Mateo llega a las 10:00', Icons.healing_outlined),
        MetricItem('Comedor', 'Cambio eventual viernes', Icons.restaurant),
      ],
    );
  }
}

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Fotos',
      subtitle: 'Momentos autorizados',
      icon: Icons.photo_library_outlined,
      actionLabel: 'Subir fotos',
      items: [
        MetricItem('Pintura', '4 fotos nuevas', Icons.palette_outlined),
        MetricItem('Musica', '2 videos', Icons.music_note_outlined),
      ],
    );
  }
}

class AuthorizedPickupsScreen extends StatelessWidget {
  const AuthorizedPickupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Autorizados',
      subtitle: 'Recogidas del nino',
      icon: Icons.verified_user_outlined,
      actionLabel: 'Nueva autorizacion',
      items: [
        MetricItem('Carlos', 'Padre · autorizado', Icons.person_outline),
        MetricItem('Maria', 'Abuela · solo hoy', Icons.today_outlined),
      ],
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Asistencia',
      subtitle: 'Entrada y salida QR',
      icon: Icons.qr_code_scanner,
      actionLabel: 'Escanear QR',
      items: [
        MetricItem('Mateo', 'Entrada 08:37', Icons.login_outlined),
        MetricItem('Clase Mariposas', '11 / 13 presentes', Icons.groups),
      ],
    );
  }
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Comunicados',
      subtitle: 'Avisos del centro',
      icon: Icons.campaign_outlined,
      actionLabel: 'Publicar comunicado',
      items: [
        MetricItem('Salida mensual', '52 / 64 leidos', Icons.mark_email_read),
        MetricItem('Recordatorio', 'Traer mochila y agua', Icons.notifications),
      ],
    );
  }
}

class ChildrenScreen extends StatelessWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleModuleScreen(
      title: 'Alumnos',
      subtitle: 'Expedientes y aulas',
      icon: Icons.child_care_outlined,
      actionLabel: 'Nueva alta',
      items: [
        MetricItem('Mateo', 'Clase Mariposas', Icons.child_care),
        MetricItem('Documentos', '4 pendientes', Icons.description_outlined),
      ],
    );
  }
}

class DailyReportFormScreen extends StatefulWidget {
  const DailyReportFormScreen({super.key});

  @override
  State<DailyReportFormScreen> createState() => _DailyReportFormScreenState();
}

class _DailyReportFormScreenState extends State<DailyReportFormScreen> {
  final _centerId = TextEditingController();
  final _childId = TextEditingController();
  final _reportDate = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  String _breakfast = 'Todo';
  String _lunch = 'Bastante';
  String _snack = 'Poco';
  String _morningPoop = 'No';
  String _afternoonPoop = 'Si';
  String _morningSleep = 'Bien';
  String _afternoonSleep = 'Bien';
  final _morningSleepTime = TextEditingController(text: '12:50');
  final _afternoonSleepTime = TextEditingController(text: '14:50');
  final _schoolNotes = TextEditingController(
    text: 'Traer suero fisiologico y cochecito.',
  );
  final _homeNotes = TextEditingController();
  final _medication = TextEditingController();

  @override
  void dispose() {
    _centerId.dispose();
    _childId.dispose();
    _reportDate.dispose();
    _morningSleepTime.dispose();
    _afternoonSleepTime.dispose();
    _schoolNotes.dispose();
    _homeNotes.dispose();
    _medication.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de Mateo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const HeaderBlock(
              title: 'Mateo',
              subtitle: 'Registro diario',
              metric: 'Martes 15 de septiembre',
              icon: Icons.edit_note_outlined,
            ),
            if (isSupabaseConfigured)
              FormSection(
                title: 'Registro',
                children: [
                  AppTextField(
                    controller: _centerId,
                    label: 'ID del centro',
                    icon: Icons.apartment_outlined,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _childId,
                    label: 'ID del nino',
                    icon: Icons.child_care_outlined,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _reportDate,
                    label: 'Fecha',
                    icon: Icons.event_outlined,
                    hint: 'AAAA-MM-DD',
                    validator: birthDateField,
                  ),
                ],
              ),
            FormSection(
              title: 'Ha comido',
              children: [
                ChoiceLine(
                  label: 'Desayuno',
                  value: _breakfast,
                  options: const ['Todo', 'Bastante', 'Poco', 'Nada'],
                  onChanged: (value) => setState(() => _breakfast = value),
                ),
                ChoiceLine(
                  label: 'Comida',
                  value: _lunch,
                  options: const ['Todo', 'Bastante', 'Poco', 'Nada'],
                  onChanged: (value) => setState(() => _lunch = value),
                ),
                ChoiceLine(
                  label: 'Merienda',
                  value: _snack,
                  options: const ['Todo', 'Bastante', 'Poco', 'Nada'],
                  onChanged: (value) => setState(() => _snack = value),
                ),
              ],
            ),
            FormSection(
              title: 'Deposiciones',
              children: [
                ChoiceLine(
                  label: 'Manana',
                  value: _morningPoop,
                  options: const ['Si', 'No'],
                  onChanged: (value) => setState(() => _morningPoop = value),
                ),
                ChoiceLine(
                  label: 'Tarde',
                  value: _afternoonPoop,
                  options: const ['Si', 'No'],
                  onChanged: (value) => setState(() => _afternoonPoop = value),
                ),
              ],
            ),
            FormSection(
              title: 'Ha dormido',
              children: [
                ChoiceLine(
                  label: 'Manana',
                  value: _morningSleep,
                  options: const ['Bien', 'Mal', 'No'],
                  onChanged: (value) => setState(() => _morningSleep = value),
                ),
                AppTextField(
                  controller: _morningSleepTime,
                  label: 'Hora manana',
                  icon: Icons.schedule_outlined,
                ),
                ChoiceLine(
                  label: 'Tarde',
                  value: _afternoonSleep,
                  options: const ['Bien', 'Mal', 'No'],
                  onChanged: (value) => setState(() => _afternoonSleep = value),
                ),
                AppTextField(
                  controller: _afternoonSleepTime,
                  label: 'Hora tarde',
                  icon: Icons.schedule_outlined,
                ),
              ],
            ),
            FormSection(
              title: 'Notas',
              children: [
                AppTextField(
                  controller: _schoolNotes,
                  label: 'Observaciones de la escuela',
                  icon: Icons.school_outlined,
                  maxLines: 3,
                ),
                AppTextField(
                  controller: _homeNotes,
                  label: 'Observaciones de casa',
                  icon: Icons.home_outlined,
                  maxLines: 3,
                ),
                AppTextField(
                  controller: _medication,
                  label: 'Medicacion',
                  icon: Icons.medication_outlined,
                  maxLines: 2,
                ),
              ],
            ),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saveDailyReport,
                icon: const Icon(Icons.check_outlined),
                label: const Text('Guardar agenda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDailyReport() async {
    if (isSupabaseConfigured) {
      final missing = requiredField(_centerId.text) ??
          requiredField(_childId.text) ??
          birthDateField(_reportDate.text);
      if (missing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(missing)),
        );
        return;
      }

      try {
        await Supabase.instance.client.from('daily_reports').upsert({
          'center_id': _centerId.text.trim(),
          'child_id': _childId.text.trim(),
          'report_date': _reportDate.text.trim(),
          'breakfast': mealToDb(_breakfast),
          'lunch': mealToDb(_lunch),
          'snack': mealToDb(_snack),
          'morning_bowel_movement': _morningPoop == 'Si',
          'afternoon_bowel_movement': _afternoonPoop == 'Si',
          'morning_sleep': sleepToDb(_morningSleep),
          'morning_sleep_time': emptyToNull(_morningSleepTime.text),
          'afternoon_sleep': sleepToDb(_afternoonSleep),
          'afternoon_sleep_time': emptyToNull(_afternoonSleepTime.text),
          'school_notes': emptyToNull(_schoolNotes.text),
          'home_notes': emptyToNull(_homeNotes.text),
          'medication': emptyToNull(_medication.text),
          'created_by': Supabase.instance.client.auth.currentUser?.id,
          'updated_by': Supabase.instance.client.auth.currentUser?.id,
        }, onConflict: 'child_id,report_date');
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agenda guardada')),
    );
    Navigator.of(context).pop();
  }
}

class ChoiceLine extends StatelessWidget {
  const ChoiceLine({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: [
              for (final option in options)
                ButtonSegment(value: option, label: Text(option)),
            ],
            selected: {value},
            onSelectionChanged: (selection) => onChanged(selection.single),
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }
}

class EnrollmentFormScreen extends StatefulWidget {
  const EnrollmentFormScreen({super.key});

  @override
  State<EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends State<EnrollmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _centerId = TextEditingController();
  final _classroomId = TextEditingController();
  final _childName = TextEditingController();
  final _birthDate = TextEditingController();
  final _allergies = TextEditingController();
  final _medicalNotes = TextEditingController();
  final _notes = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();
  final _fatherName = TextEditingController();
  final _fatherEmail = TextEditingController();
  final _fatherPhone = TextEditingController();
  final _motherName = TextEditingController();
  final _motherEmail = TextEditingController();
  final _motherPhone = TextEditingController();
  final _educatorName = TextEditingController();
  final _educatorEmail = TextEditingController();
  String _sex = 'not_specified';
  bool _submitting = false;

  @override
  void dispose() {
    for (final controller in [
      _centerId,
      _classroomId,
      _childName,
      _birthDate,
      _allergies,
      _medicalNotes,
      _notes,
      _emergencyName,
      _emergencyPhone,
      _fatherName,
      _fatherEmail,
      _fatherPhone,
      _motherName,
      _motherEmail,
      _motherPhone,
      _educatorName,
      _educatorEmail,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva alta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const HeaderBlock(
                title: 'Expediente y accesos',
                subtitle: 'Direccion',
                metric: 'Crea el perfil del nino e invita a la familia',
                icon: Icons.assignment_ind_outlined,
              ),
              const SizedBox(height: 16),
              FormSection(
                title: 'Centro',
                children: [
                  AppTextField(
                    controller: _centerId,
                    label: 'ID del centro',
                    icon: Icons.apartment_outlined,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _classroomId,
                    label: 'ID del aula',
                    icon: Icons.meeting_room_outlined,
                  ),
                ],
              ),
              FormSection(
                title: 'Nino',
                children: [
                  AppTextField(
                    controller: _childName,
                    label: 'Nombre completo',
                    icon: Icons.child_care_outlined,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _birthDate,
                    label: 'Fecha de nacimiento',
                    icon: Icons.event_outlined,
                    hint: 'AAAA-MM-DD',
                    validator: birthDateField,
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'girl', label: Text('Chica')),
                      ButtonSegment(value: 'boy', label: Text('Chico')),
                      ButtonSegment(
                        value: 'not_specified',
                        label: Text('Sin definir'),
                      ),
                    ],
                    selected: {_sex},
                    onSelectionChanged: (value) {
                      setState(() => _sex = value.single);
                    },
                    showSelectedIcon: false,
                  ),
                  AppTextField(
                    controller: _allergies,
                    label: 'Alergias o intolerancias',
                    icon: Icons.health_and_safety_outlined,
                  ),
                  AppTextField(
                    controller: _medicalNotes,
                    label: 'Salud y medicacion',
                    icon: Icons.medical_information_outlined,
                    maxLines: 3,
                  ),
                  AppTextField(
                    controller: _notes,
                    label: 'Observaciones',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                ],
              ),
              FormSection(
                title: 'Emergencia',
                children: [
                  AppTextField(
                    controller: _emergencyName,
                    label: 'Contacto de emergencia',
                    icon: Icons.contact_emergency_outlined,
                  ),
                  AppTextField(
                    controller: _emergencyPhone,
                    label: 'Telefono de emergencia',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              FormSection(
                title: 'Familia',
                children: [
                  AppTextField(
                    controller: _fatherName,
                    label: 'Nombre padre o tutor',
                    icon: Icons.person_outline,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _fatherEmail,
                    label: 'Email padre o tutor',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: emailField,
                  ),
                  AppTextField(
                    controller: _fatherPhone,
                    label: 'Telefono padre o tutor',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  AppTextField(
                    controller: _motherName,
                    label: 'Nombre madre o tutora',
                    icon: Icons.person_outline,
                  ),
                  AppTextField(
                    controller: _motherEmail,
                    label: 'Email madre o tutora',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: optionalEmailField,
                  ),
                  AppTextField(
                    controller: _motherPhone,
                    label: 'Telefono madre o tutora',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              FormSection(
                title: 'Educadora',
                children: [
                  AppTextField(
                    controller: _educatorName,
                    label: 'Nombre educadora',
                    icon: Icons.badge_outlined,
                  ),
                  AppTextField(
                    controller: _educatorEmail,
                    label: 'Email educadora',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: optionalEmailField,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(_submitting ? 'Creando alta' : 'Crear e invitar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final guardians = [
      {
        'fullName': _fatherName.text.trim(),
        'email': _fatherEmail.text.trim(),
        'relationship': 'Padre/tutor',
        'phone': _fatherPhone.text.trim(),
        'canPickUp': true,
      },
      if (_motherEmail.text.trim().isNotEmpty)
        {
          'fullName': _motherName.text.trim().isEmpty
              ? 'Madre/tutora'
              : _motherName.text.trim(),
          'email': _motherEmail.text.trim(),
          'relationship': 'Madre/tutora',
          'phone': _motherPhone.text.trim(),
          'canPickUp': true,
        },
    ];

    final educators = [
      if (_educatorEmail.text.trim().isNotEmpty)
        {
          'fullName': _educatorName.text.trim().isEmpty
              ? 'Educadora'
              : _educatorName.text.trim(),
          'email': _educatorEmail.text.trim(),
        },
    ];

    final payload = {
      'centerId': _centerId.text.trim(),
      'classroomId':
          _classroomId.text.trim().isEmpty ? null : _classroomId.text.trim(),
      'child': {
        'fullName': _childName.text.trim(),
        'birthDate': _birthDate.text.trim(),
        'sex': _sex,
        'allergies': _allergies.text.trim(),
        'medicalNotes': _medicalNotes.text.trim(),
        'notes': _notes.text.trim(),
        'emergencyContactName': _emergencyName.text.trim(),
        'emergencyContactPhone': _emergencyPhone.text.trim(),
      },
      'guardians': guardians,
      'educators': educators,
    };

    try {
      if (isSupabaseConfigured) {
        await Supabase.instance.client.functions.invoke(
          'create-enrollment',
          body: payload,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSupabaseConfigured
                ? 'Alta enviada. La familia recibira acceso por email.'
                : 'Alta preparada en modo demo.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on FunctionException catch (error) {
      _showError(error.details?.toString() ?? error.reasonPhrase ?? 'Error');
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          ...children.expand(
            (child) => [child, const SizedBox(height: 10)],
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class HeaderBlock extends StatelessWidget {
  const HeaderBlock({
    super.key,
    required this.title,
    required this.subtitle,
    required this.metric,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String metric;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 42, color: colors.onPrimaryContainer),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(metric),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: colors.surface,
      side: BorderSide(color: colors.outlineVariant),
    );
  }
}

class MetricItem {
  const MetricItem(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;
}

class ChildRow {
  const ChildRow(this.name, this.food, this.sleep, this.diaper, this.note);

  final String name;
  final String food;
  final String sleep;
  final String diaper;
  final String note;
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

String mealToDb(String value) {
  return switch (value) {
    'Todo' => 'all',
    'Bastante' => 'most',
    'Poco' => 'little',
    _ => 'none',
  };
}

String sleepToDb(String value) {
  return switch (value) {
    'Bien' => 'good',
    'Mal' => 'bad',
    _ => 'none',
  };
}

String? emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
