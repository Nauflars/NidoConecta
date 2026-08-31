import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app_repository.dart';
import 'src/application/admin_content_payloads.dart';
import 'src/application/daily_report_payloads.dart';
import 'src/application/enrollment_payload.dart';
import 'src/application/module_action_payloads.dart';
import 'src/domain/nido_domain.dart';

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
    const seed = NidoColors.primary;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NidoConecta',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: NidoColors.canvas,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: NidoColors.canvas,
          foregroundColor: NidoColors.ink,
          titleTextStyle: TextStyle(
            color: NidoColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: NidoColors.line),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          prefixIconColor: NidoColors.muted,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: NidoColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: NidoColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: NidoColors.primary, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: NidoColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            side: const WidgetStatePropertyAll(
                BorderSide(color: NidoColors.line)),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
      home: isSupabaseConfigured ? const AuthGate() : const HomeShell(),
    );
  }
}

class NidoColors {
  static const primary = Color(0xFF2757D8);
  static const ink = Color(0xFF182230);
  static const muted = Color(0xFF667085);
  static const canvas = Color(0xFFF3F6FB);
  static const line = Color(0xFFDDE3EE);
  static const blush = Color(0xFFFF6B8A);
  static const mint = Color(0xFF16A085);
  static const amber = Color(0xFFF4A62A);
  static const sky = Color(0xFF43A6F6);
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
              shrinkWrap: true,
              children: [
                const Center(child: BrandMark(size: 56)),
                const SizedBox(height: 18),
                Text(
                  'NidoConecta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Accede con el email que recibiste del centro.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: NidoColors.muted,
                      ),
                ),
                const SizedBox(height: 24),
                FormSection(
                  title: 'Entrar',
                  children: [
                    AppTextField(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: emailField,
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contrasena',
                        prefixIcon: Icon(Icons.password_outlined),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _signIn,
                        icon: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login_outlined),
                        label: Text(_loading ? 'Entrando' : 'Entrar'),
                      ),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text('Cambiar o recuperar contrasena'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
  late final Future<AppContextData> _contextFuture;

  @override
  void initState() {
    super.initState();
    _contextFuture = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    ).loadContext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: 34),
            SizedBox(width: 10),
            Text('NidoConecta'),
          ],
        ),
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
        child: FutureBuilder<AppContextData>(
          future: _contextFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final appContext = snapshot.data ?? AppRepository.demoContext();
            final selectedRole =
                appContext.isDemo ? _role : appRoleFromContext(appContext.role);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    if (appContext.isDemo)
                      RoleSelector(selected: _role, onChanged: _setRole)
                    else
                      StatusPill(
                        label:
                            '${appContext.centerName} · ${roleLabel(selectedRole)}',
                        icon: Icons.verified_user_outlined,
                      ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: switch (selectedRole) {
                        AppRole.family =>
                          FamilyTodayView(appContext: appContext),
                        AppRole.educator =>
                          EducatorClassView(appContext: appContext),
                        AppRole.admin =>
                          AdminDashboardView(appContext: appContext),
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _setRole(AppRole role) {
    setState(() => _role = role);
  }
}

AppRole appRoleFromContext(NidoRole role) {
  return switch (role) {
    NidoRole.admin => AppRole.admin,
    NidoRole.educator => AppRole.educator,
    NidoRole.family => AppRole.family,
  };
}

String roleLabel(AppRole role) {
  return switch (role) {
    AppRole.admin => 'Direccion',
    AppRole.educator => 'Educadora',
    AppRole.family => 'Familia',
  };
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

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NidoColors.primary, NidoColors.blush],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.48,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class FamilyTodayView extends StatelessWidget {
  const FamilyTodayView({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  Widget build(BuildContext context) {
    final child = appContext.selectedChild;

    return Column(
      key: const ValueKey('family'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderBlock(
          title: child.fullName,
          subtitle: 'Agenda diaria',
          metric: '${child.classroomName} · hoy',
          icon: Icons.child_care,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final timeline =
                FamilyAgendaLoader(appContext: appContext, child: child);

            final actions = Column(
              children: [
                PrimaryActionButton(
                  label: 'Enviar informacion de casa',
                  icon: Icons.home_work_outlined,
                  onPressed: () => openModule(
                    context,
                    HomeReportFormScreen(appContext: appContext, child: child),
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryActionButton(
                  label: 'Enviar mensaje',
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => openModule(
                    context,
                    MessagesScreen(appContext: appContext),
                  ),
                ),
                const SizedBox(height: 16),
                ModuleGrid(
                  appContext: appContext,
                  modules: [
                    AppModule(
                      'Calendario',
                      Icons.event_outlined,
                      CalendarScreen(appContext: appContext),
                    ),
                    AppModule(
                      'Menu',
                      Icons.restaurant_menu_outlined,
                      MenuScreen(appContext: appContext),
                    ),
                    AppModule(
                      'Fotos',
                      Icons.photo_library_outlined,
                      MediaScreen(appContext: appContext),
                    ),
                    AppModule(
                      'Autorizados',
                      Icons.verified_user_outlined,
                      AuthorizedPickupsScreen(appContext: appContext),
                    ),
                  ],
                ),
              ],
            );

            if (constraints.maxWidth < 760) {
              return Column(
                children: [
                  timeline,
                  const SizedBox(height: 16),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: timeline),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: actions),
              ],
            );
          },
        ),
      ],
    );
  }
}

class DailyNotebookCard extends StatelessWidget {
  const DailyNotebookCard({super.key, required this.report});

  final DailyReportData report;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NidoColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEAF0FF),
                child:
                    Icon(Icons.restaurant_outlined, color: NidoColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agenda de hoy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'Comida, descanso y cuidados',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: NidoColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: colors.outline),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('Ha comido'),
          FoodStatusRow(meal: 'Desayuno', amount: report.breakfast),
          FoodStatusRow(meal: 'Comida', amount: report.lunch),
          FoodStatusRow(meal: 'Merienda', amount: report.snack),
          const Divider(height: 24),
          const SectionTitle('Deposiciones'),
          DayPartStatus(
            label: 'Manana',
            value: report.morningBowelMovement ? 'Si' : 'No',
          ),
          DayPartStatus(
            label: 'Tarde',
            value: report.afternoonBowelMovement ? 'Si' : 'No',
          ),
          const Divider(height: 24),
          const SectionTitle('Ha dormido'),
          SleepStatus(
            label: 'Manana',
            quality: report.morningSleep,
            time: report.morningSleepTime ?? '-',
          ),
          SleepStatus(
            label: 'Tarde',
            quality: report.afternoonSleep,
            time: report.afternoonSleepTime ?? '-',
          ),
        ],
      ),
    );
  }
}

class DailyNotebookLoader extends StatelessWidget {
  const DailyNotebookLoader({
    super.key,
    required this.appContext,
    required this.child,
  });

  final AppContextData appContext;
  final ChildSummary child;

  @override
  Widget build(BuildContext context) {
    if (appContext.isDemo) {
      return DailyNotebookCard(report: demoDailyReport(child.id));
    }

    return FutureBuilder<DailyReportData?>(
      future: AppRepository(
        client: Supabase.instance.client,
      ).loadTodayReport(child.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return DailyNotebookCard(
          report: snapshot.data ?? demoDailyReport(child.id),
        );
      },
    );
  }
}

class FamilyAgendaLoader extends StatelessWidget {
  const FamilyAgendaLoader({
    super.key,
    required this.appContext,
    required this.child,
  });

  final AppContextData appContext;
  final ChildSummary child;

  @override
  Widget build(BuildContext context) {
    if (appContext.isDemo) {
      return FamilyAgendaContent(report: demoDailyReport(child.id));
    }

    return FutureBuilder<DailyReportData?>(
      future: AppRepository(
        client: Supabase.instance.client,
      ).loadTodayReport(child.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return NoteCard(
            title: 'No se pudo cargar la agenda',
            text: snapshot.error.toString(),
          );
        }

        return FamilyAgendaContent(
          report: snapshot.data ?? demoDailyReport(child.id),
        );
      },
    );
  }
}

class FamilyAgendaContent extends StatelessWidget {
  const FamilyAgendaContent({super.key, required this.report});

  final DailyReportData report;

  @override
  Widget build(BuildContext context) {
    final notes = [
      (
        title: 'Observaciones de la escuela',
        text: report.schoolNotes,
      ),
      (
        title: 'Observaciones de casa',
        text: report.homeNotes,
      ),
      (
        title: 'Medicacion',
        text: report.medication,
      ),
    ];

    return Column(
      children: [
        DailyNotebookCard(report: report),
        for (final note in notes)
          if ((note.text ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            NoteCard(title: note.title, text: note.text!.trim()),
          ],
      ],
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? colors.primary : const Color(0xFFF3F6FB),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? colors.primary : NidoColors.line,
                width: selected ? 5 : 1,
              ),
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
  const EducatorClassView({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  Widget build(BuildContext context) {
    final selectedChild = appContext.selectedChild;

    return Column(
      key: const ValueKey('educator'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderBlock(
          title: selectedChild.classroomName,
          subtitle: 'Panel de educadora',
          metric: 'Registro rapido',
          icon: Icons.groups,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            QuickAction(
              label: 'Entrada',
              icon: Icons.qr_code_scanner,
              onPressed: () => openModule(
                context,
                AttendanceEventFormScreen(
                  appContext: appContext,
                  child: selectedChild,
                  eventType: 'check_in',
                ),
              ),
            ),
            QuickAction(
              label: 'Comida',
              icon: Icons.restaurant,
              onPressed: () => openModule(
                context,
                DailyReportFormScreen(
                  appContext: appContext,
                  child: selectedChild,
                ),
              ),
            ),
            QuickAction(
              label: 'Siesta',
              icon: Icons.bedtime,
              onPressed: () => openModule(
                context,
                DailyReportFormScreen(
                  appContext: appContext,
                  child: selectedChild,
                ),
              ),
            ),
            QuickAction(
              label: 'Pañal',
              icon: Icons.checklist,
              onPressed: () => openModule(
                context,
                DailyReportFormScreen(
                  appContext: appContext,
                  child: selectedChild,
                ),
              ),
            ),
            QuickAction(
              label: 'Fotos',
              icon: Icons.add_a_photo,
              onPressed: () => openModule(
                context,
                MediaScreen(appContext: appContext),
              ),
            ),
            QuickAction(
              label: 'Mensaje',
              icon: Icons.forum_outlined,
              onPressed: () => openModule(
                context,
                MessageFormScreen(appContext: appContext),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryActionButton(
          label: 'Registrar agenda de ${selectedChild.fullName}',
          icon: Icons.edit_note_outlined,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DailyReportFormScreen(
                  appContext: appContext,
                  child: selectedChild,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ModuleGrid(
          appContext: appContext,
          modules: [
            AppModule(
              'Asistencia',
              Icons.qr_code_scanner,
              AttendanceScreen(appContext: appContext),
            ),
            AppModule(
              'Mensajes',
              Icons.forum_outlined,
              MessagesScreen(appContext: appContext),
            ),
            AppModule(
              'Fotos',
              Icons.add_a_photo_outlined,
              MediaScreen(appContext: appContext),
            ),
            AppModule(
              'Calendario',
              Icons.event_outlined,
              CalendarScreen(appContext: appContext),
            ),
          ],
        ),
        const SizedBox(height: 16),
        EducatorStatusTable(appContext: appContext),
      ],
    );
  }
}

class EducatorStatusTable extends StatelessWidget {
  const EducatorStatusTable({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  Widget build(BuildContext context) {
    final repository = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    );

    return FutureBuilder<List<EducatorChildStatus>>(
      future: repository.loadEducatorStatuses(appContext),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return NoteCard(
            title: 'No se pudo cargar la agenda',
            text: snapshot.error.toString(),
          );
        }

        final rows = snapshot.data ?? const [];
        if (rows.isEmpty) {
          return const NoteCard(
            title: 'Sin alumnos',
            text: 'Todavia no hay alumnos asignados a esta educadora.',
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 42,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 56,
            columns: const [
              DataColumn(label: Text('Nino')),
              DataColumn(label: Text('Aula')),
              DataColumn(label: Text('Comida')),
              DataColumn(label: Text('Siesta')),
              DataColumn(label: Text('Panal')),
              DataColumn(label: Text('Nota')),
            ],
            rows: [
              for (final row in rows)
                DataRow(
                  cells: [
                    DataCell(Text(row.child.fullName)),
                    DataCell(Text(row.child.classroomName)),
                    DataCell(Text(row.food)),
                    DataCell(Text(row.sleep)),
                    DataCell(Text(row.diaper)),
                    DataCell(Text(row.note.isEmpty ? '-' : row.note)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('admin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderBlock(
          title: appContext.centerName,
          subtitle: 'Panel de direccion',
          metric: 'Curso 2026-2027',
          icon: Icons.apartment,
        ),
        const SizedBox(height: 12),
        AdminMetricsGrid(appContext: appContext),
        const SizedBox(height: 16),
        PrimaryActionButton(
          label: 'Nueva alta',
          icon: Icons.person_add_alt_1_outlined,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EnrollmentFormScreen(appContext: appContext),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ModuleGrid(
          appContext: appContext,
          modules: [
            AppModule(
              'Alumnos',
              Icons.child_care_outlined,
              ChildrenScreen(appContext: appContext),
            ),
            AppModule(
              'Educadoras',
              Icons.badge_outlined,
              StaffScreen(appContext: appContext),
            ),
            AppModule(
              'Comunicados',
              Icons.campaign_outlined,
              AnnouncementsScreen(appContext: appContext),
            ),
            AppModule(
              'Calendario',
              Icons.event_outlined,
              CalendarScreen(appContext: appContext),
            ),
            AppModule(
              'Menu',
              Icons.restaurant_menu_outlined,
              MenuScreen(appContext: appContext),
            ),
            AppModule(
              'Fotos',
              Icons.collections_outlined,
              MediaScreen(appContext: appContext),
            ),
            AppModule(
              'Mensajes',
              Icons.forum_outlined,
              MessagesScreen(appContext: appContext),
            ),
          ],
        ),
      ],
    );
  }
}

class AdminMetricsGrid extends StatelessWidget {
  const AdminMetricsGrid({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminDashboardData>(
      future: AppRepository(
        client: isSupabaseConfigured ? Supabase.instance.client : null,
      ).loadAdminDashboard(appContext.centerId),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final items = [
          MetricItem(
            'NiÃ±os',
            data == null ? '...' : '${data.childrenCount}',
            Icons.child_care_outlined,
          ),
          MetricItem(
            'Educadoras',
            data == null ? '...' : '${data.educatorsCount}',
            Icons.badge_outlined,
          ),
          MetricItem(
            'Agendas hoy',
            data == null ? '...' : '${data.todayReportsCount}',
            Icons.edit_note_outlined,
          ),
          MetricItem(
            'Entradas QR',
            data == null ? '...' : '${data.todayAttendanceCount}',
            Icons.qr_code_scanner,
          ),
          MetricItem(
            'Mensajes',
            data == null ? '...' : '${data.messagesCount}',
            Icons.mark_unread_chat_alt_outlined,
          ),
          MetricItem(
            'Fotos',
            data == null ? '...' : '${data.mediaCount}',
            Icons.collections_outlined,
          ),
        ];

        return LayoutBuilder(
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
        );
      },
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
  const ModuleGrid(
      {super.key, required this.appContext, required this.modules});

  final AppContextData appContext;
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
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: NidoColors.line),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => openModule(context, module.screen),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF0FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(module.icon, color: NidoColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            module.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: NidoColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
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
    this.appContext,
    this.kind,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
    this.actionLabel,
    this.onActionPressed,
  });

  final AppContextData? appContext;
  final ModuleKind? kind;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<MetricItem> items;
  final String? actionLabel;
  final Future<void> Function(BuildContext context)? onActionPressed;

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
            if (actionLabel != null && onActionPressed != null) ...[
              PrimaryActionButton(
                label: actionLabel!,
                icon: Icons.add,
                onPressed: () => onActionPressed!(context),
              ),
              const SizedBox(height: 12),
            ],
            if (appContext == null || kind == null)
              StaticModuleItems(items: items)
            else
              ModuleItemsList(
                appContext: appContext!,
                kind: kind!,
                icon: icon,
                fallbackItems: items,
              ),
          ],
        ),
      ),
    );
  }
}

class ModuleItemsList extends StatelessWidget {
  const ModuleItemsList({
    super.key,
    required this.appContext,
    required this.kind,
    required this.icon,
    required this.fallbackItems,
  });

  final AppContextData appContext;
  final ModuleKind kind;
  final IconData icon;
  final List<MetricItem> fallbackItems;

  @override
  Widget build(BuildContext context) {
    if (appContext.isDemo || !isSupabaseConfigured) {
      return StaticModuleItems(items: fallbackItems);
    }

    return FutureBuilder<List<MetricItemData>>(
      future: AppRepository(
        client: Supabase.instance.client,
      ).loadModuleItems(appContext.centerId, kind),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return NoteCard(
            title: 'No se pudo cargar',
            text: snapshot.error.toString(),
          );
        }
        final rows = snapshot.data ?? const [];
        if (rows.isEmpty) {
          return const NoteCard(
            title: 'Sin datos',
            text: 'Todavia no hay registros reales en este modulo.',
          );
        }
        return Column(
          children: [
            for (final row in rows) ...[
              InfoTile(title: row.title, value: row.value, icon: icon),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class StaticModuleItems extends StatelessWidget {
  const StaticModuleItems({super.key, required this.items});

  final List<MetricItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          InfoTile(title: item.title, value: item.value, icon: item.icon),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.calendar,
      title: 'Calendario',
      subtitle: 'Eventos y festivos',
      icon: Icons.event_outlined,
      actionLabel: 'Nuevo evento',
      onActionPressed: appContext == null
          ? null
          : (screenContext) async {
              final created = await Navigator.of(screenContext).push<bool>(
                MaterialPageRoute(
                  builder: (_) => CalendarEventFormScreen(
                    appContext: appContext!,
                  ),
                ),
              );
              if (created == true && screenContext.mounted) {
                Navigator.of(screenContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => CalendarScreen(appContext: appContext),
                  ),
                );
              }
            },
      items: const [
        MetricItem('Viernes', 'Salida mensual', Icons.directions_bus_outlined),
        MetricItem('Lunes', 'Centro cerrado', Icons.event_busy_outlined),
      ],
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.menu,
      title: 'Menu',
      subtitle: 'Comedor mensual',
      icon: Icons.restaurant_menu_outlined,
      actionLabel: 'Importar menu',
      items: const [
        MetricItem('Hoy', 'Macarrones · merluza · fruta', Icons.restaurant),
        MetricItem('Alergias', '2 dietas especiales', Icons.health_and_safety),
      ],
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.messages,
      title: 'Mensajes',
      subtitle: 'Conversaciones por categoria',
      icon: Icons.forum_outlined,
      actionLabel: 'Nuevo mensaje',
      onActionPressed: appContext == null
          ? null
          : (screenContext) async {
              final created = await Navigator.of(screenContext).push<bool>(
                MaterialPageRoute(
                  builder: (_) => MessageFormScreen(appContext: appContext!),
                ),
              );
              if (created == true && screenContext.mounted) {
                Navigator.of(screenContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MessagesScreen(appContext: appContext),
                  ),
                );
              }
            },
      items: const [
        MetricItem('Salud', 'Mateo llega a las 10:00', Icons.healing_outlined),
        MetricItem('Comedor', 'Cambio eventual viernes', Icons.restaurant),
      ],
    );
  }
}

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.media,
      title: 'Fotos',
      subtitle: 'Momentos autorizados',
      icon: Icons.photo_library_outlined,
      actionLabel: 'Registrar foto',
      onActionPressed: appContext == null ||
              (!appContext!.isDemo && appContext!.role == NidoRole.family)
          ? null
          : (screenContext) async {
              final created = await Navigator.of(screenContext).push<bool>(
                MaterialPageRoute(
                  builder: (_) => MediaAssetFormScreen(
                    appContext: appContext!,
                  ),
                ),
              );
              if (created == true && screenContext.mounted) {
                Navigator.of(screenContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MediaScreen(appContext: appContext),
                  ),
                );
              }
            },
      items: const [
        MetricItem('Pintura', '4 fotos nuevas', Icons.palette_outlined),
        MetricItem('Musica', '2 videos', Icons.music_note_outlined),
      ],
    );
  }
}

class AuthorizedPickupsScreen extends StatelessWidget {
  const AuthorizedPickupsScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.pickups,
      title: 'Autorizados',
      subtitle: 'Recogidas del nino',
      icon: Icons.verified_user_outlined,
      actionLabel: 'Nueva autorizacion',
      items: const [
        MetricItem('Carlos', 'Padre · autorizado', Icons.person_outline),
        MetricItem('Maria', 'Abuela · solo hoy', Icons.today_outlined),
      ],
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.attendance,
      title: 'Asistencia',
      subtitle: 'Entrada y salida QR',
      icon: Icons.qr_code_scanner,
      actionLabel: 'Escanear QR',
      onActionPressed: appContext == null
          ? null
          : (screenContext) async {
              final created = await Navigator.of(screenContext).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AttendanceEventFormScreen(
                    appContext: appContext!,
                    child: appContext!.selectedChild,
                    eventType: 'check_in',
                  ),
                ),
              );
              if (created == true && screenContext.mounted) {
                Navigator.of(screenContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => AttendanceScreen(appContext: appContext),
                  ),
                );
              }
            },
      items: const [
        MetricItem('Mateo', 'Entrada 08:37', Icons.login_outlined),
        MetricItem('Clase Mariposas', '11 / 13 presentes', Icons.groups),
      ],
    );
  }
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.announcements,
      title: 'Comunicados',
      subtitle: 'Avisos del centro',
      icon: Icons.campaign_outlined,
      actionLabel: 'Publicar comunicado',
      onActionPressed: appContext == null
          ? null
          : (screenContext) async {
              final created = await Navigator.of(screenContext).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AnnouncementFormScreen(
                    appContext: appContext!,
                  ),
                ),
              );
              if (created == true && screenContext.mounted) {
                Navigator.of(screenContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => AnnouncementsScreen(appContext: appContext),
                  ),
                );
              }
            },
      items: const [
        MetricItem('Salida mensual', '52 / 64 leidos', Icons.mark_email_read),
        MetricItem('Recordatorio', 'Traer mochila y agua', Icons.notifications),
      ],
    );
  }
}

class ChildrenScreen extends StatelessWidget {
  const ChildrenScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.children,
      title: 'Alumnos',
      subtitle: 'Expedientes y aulas',
      icon: Icons.child_care_outlined,
      actionLabel: 'Nueva alta',
      onActionPressed: appContext == null
          ? null
          : (screenContext) async {
              await Navigator.of(screenContext).push(
                MaterialPageRoute(
                  builder: (_) => EnrollmentFormScreen(
                    appContext: appContext!,
                  ),
                ),
              );
            },
      items: const [
        MetricItem('Mateo', 'Clase Mariposas', Icons.child_care),
        MetricItem('Documentos', '4 pendientes', Icons.description_outlined),
      ],
    );
  }
}

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key, this.appContext});

  final AppContextData? appContext;

  @override
  Widget build(BuildContext context) {
    return SimpleModuleScreen(
      appContext: appContext,
      kind: ModuleKind.staff,
      title: 'Educadoras',
      subtitle: 'Equipo del centro',
      icon: Icons.badge_outlined,
      items: const [
        MetricItem('Laura Marti', 'Educadora', Icons.badge_outlined),
        MetricItem('Marta Soler', 'Educadora', Icons.badge_outlined),
      ],
    );
  }
}

class AnnouncementFormScreen extends StatefulWidget {
  const AnnouncementFormScreen({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo comunicado')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              HeaderBlock(
                title: 'Nuevo comunicado',
                subtitle: widget.appContext.centerName,
                metric: 'Visible para educadoras y familias',
                icon: Icons.campaign_outlined,
              ),
              const SizedBox(height: 16),
              FormSection(
                title: 'Contenido',
                children: [
                  AppTextField(
                    controller: _title,
                    label: 'Titulo',
                    icon: Icons.title_outlined,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _body,
                    label: 'Mensaje',
                    icon: Icons.notes_outlined,
                    maxLines: 5,
                    validator: requiredField,
                  ),
                ],
              ),
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
                      : const Icon(Icons.publish_outlined),
                  label: Text(
                    _submitting ? 'Publicando' : 'Publicar comunicado',
                  ),
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
    final repository = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    );
    final payload = AdminContentPayloadBuilder.fromAnnouncement(
      AnnouncementDraft(
        centerId: widget.appContext.centerId,
        title: _title.text,
        body: _body.text,
        authorId: isSupabaseConfigured
            ? Supabase.instance.client.auth.currentUser?.id
            : null,
      ),
    );

    try {
      if (isSupabaseConfigured && !widget.appContext.isDemo) {
        await repository.publishAnnouncement(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comunicado publicado')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class CalendarEventFormScreen extends StatefulWidget {
  const CalendarEventFormScreen({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  State<CalendarEventFormScreen> createState() =>
      _CalendarEventFormScreenState();
}

class _CalendarEventFormScreenState extends State<CalendarEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _startsOn = TextEditingController(
    text: DateTime.now()
        .add(const Duration(days: 7))
        .toIso8601String()
        .substring(0, 10),
  );
  final _endsOn = TextEditingController();
  bool _isClosedDay = false;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _startsOn.dispose();
    _endsOn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo evento')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              HeaderBlock(
                title: 'Nuevo evento',
                subtitle: widget.appContext.centerName,
                metric: 'Calendario del centro',
                icon: Icons.event_outlined,
              ),
              const SizedBox(height: 16),
              FormSection(
                title: 'Evento',
                children: [
                  AppTextField(
                    controller: _title,
                    label: 'Titulo',
                    icon: Icons.title_outlined,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _startsOn,
                    label: 'Fecha de inicio',
                    icon: Icons.event_outlined,
                    hint: 'AAAA-MM-DD',
                    validator: dateField,
                  ),
                  AppTextField(
                    controller: _endsOn,
                    label: 'Fecha de fin',
                    icon: Icons.event_available_outlined,
                    hint: 'Opcional',
                    validator: _optionalDateField,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Centro cerrado'),
                    value: _isClosedDay,
                    onChanged: (value) {
                      setState(() => _isClosedDay = value);
                    },
                  ),
                ],
              ),
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
                      : const Icon(Icons.event_available_outlined),
                  label: Text(_submitting ? 'Creando' : 'Crear evento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _optionalDateField(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return dateField(trimmed);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final repository = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    );
    final payload = AdminContentPayloadBuilder.fromCalendarEvent(
      CalendarEventDraft(
        centerId: widget.appContext.centerId,
        title: _title.text,
        startsOn: _startsOn.text,
        endsOn: _endsOn.text,
        isClosedDay: _isClosedDay,
      ),
    );

    try {
      if (isSupabaseConfigured && !widget.appContext.isDemo) {
        await repository.createCalendarEvent(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento creado')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class MessageFormScreen extends StatefulWidget {
  const MessageFormScreen({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  State<MessageFormScreen> createState() => _MessageFormScreenState();
}

class _MessageFormScreenState extends State<MessageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _body = TextEditingController();
  String _category = 'Educadora';
  bool _submitting = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.appContext.selectedChild;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo mensaje')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              HeaderBlock(
                title: child.fullName,
                subtitle: widget.appContext.centerName,
                metric: 'Conversacion del alumno',
                icon: Icons.forum_outlined,
              ),
              const SizedBox(height: 16),
              FormSection(
                title: 'Mensaje',
                children: [
                  ChoiceLine(
                    label: 'Categoria',
                    value: _category,
                    options: const [
                      'Educadora',
                      'Salud',
                      'Comedor',
                      'Horario',
                      'Administracion',
                      'Otro',
                    ],
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  AppTextField(
                    controller: _body,
                    label: 'Texto del mensaje',
                    icon: Icons.notes_outlined,
                    maxLines: 5,
                    validator: requiredField,
                  ),
                ],
              ),
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
                  label: Text(_submitting ? 'Enviando' : 'Enviar mensaje'),
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
    final repository = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    );
    final payload = ModuleActionPayloadBuilder.fromMessage(
      MessageDraft(
        centerId: widget.appContext.centerId,
        childId: widget.appContext.selectedChild.id,
        senderId: isSupabaseConfigured
            ? Supabase.instance.client.auth.currentUser?.id
            : null,
        category: _category,
        body: _body.text,
      ),
    );

    try {
      if (isSupabaseConfigured && !widget.appContext.isDemo) {
        await repository.createMessage(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje enviado')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class AttendanceEventFormScreen extends StatefulWidget {
  const AttendanceEventFormScreen({
    super.key,
    required this.appContext,
    required this.child,
    required this.eventType,
  });

  final AppContextData appContext;
  final ChildSummary child;
  final String eventType;

  @override
  State<AttendanceEventFormScreen> createState() =>
      _AttendanceEventFormScreenState();
}

class _AttendanceEventFormScreenState extends State<AttendanceEventFormScreen> {
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCheckIn = widget.eventType == 'check_in';
    final title = isCheckIn ? 'Registrar entrada' : 'Registrar salida';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            HeaderBlock(
              title: widget.child.fullName,
              subtitle: widget.child.classroomName,
              metric: title,
              icon: isCheckIn ? Icons.login_outlined : Icons.logout_outlined,
            ),
            const SizedBox(height: 16),
            FormSection(
              title: 'Asistencia',
              children: [
                AppTextField(
                  controller: _notes,
                  label: 'Notas',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
              ],
            ),
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
                    : Icon(isCheckIn
                        ? Icons.login_outlined
                        : Icons.logout_outlined),
                label: Text(_submitting ? 'Guardando' : title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final repository = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    );
    final payload = ModuleActionPayloadBuilder.fromAttendance(
      AttendanceEventDraft(
        centerId: widget.appContext.centerId,
        childId: widget.child.id,
        actorId: isSupabaseConfigured
            ? Supabase.instance.client.auth.currentUser?.id
            : null,
        eventType: widget.eventType,
        notes: _notes.text,
      ),
    );

    try {
      if (isSupabaseConfigured && !widget.appContext.isDemo) {
        await repository.createAttendanceEvent(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asistencia registrada')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class MediaAssetFormScreen extends StatefulWidget {
  const MediaAssetFormScreen({super.key, required this.appContext});

  final AppContextData appContext;

  @override
  State<MediaAssetFormScreen> createState() => _MediaAssetFormScreenState();
}

class _MediaAssetFormScreenState extends State<MediaAssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _activity = TextEditingController();
  final _takenOn = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _activity.dispose();
    _takenOn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar foto')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              HeaderBlock(
                title: widget.appContext.selectedChild.classroomName,
                subtitle: widget.appContext.centerName,
                metric: 'Galeria del centro',
                icon: Icons.add_a_photo_outlined,
              ),
              const SizedBox(height: 16),
              FormSection(
                title: 'Foto',
                children: [
                  AppTextField(
                    controller: _title,
                    label: 'Titulo',
                    icon: Icons.title_outlined,
                    validator: requiredField,
                  ),
                  AppTextField(
                    controller: _activity,
                    label: 'Actividad',
                    icon: Icons.palette_outlined,
                  ),
                  AppTextField(
                    controller: _takenOn,
                    label: 'Fecha',
                    icon: Icons.event_outlined,
                    hint: 'AAAA-MM-DD',
                    validator: dateField,
                  ),
                ],
              ),
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
                      : const Icon(Icons.add_a_photo_outlined),
                  label: Text(_submitting ? 'Guardando' : 'Registrar foto'),
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
    final repository = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    );
    final payload = ModuleActionPayloadBuilder.fromMediaAsset(
      MediaAssetDraft(
        centerId: widget.appContext.centerId,
        childId: widget.appContext.selectedChild.id,
        uploadedBy: isSupabaseConfigured
            ? Supabase.instance.client.auth.currentUser?.id
            : null,
        title: _title.text,
        activity: _activity.text,
        takenOn: _takenOn.text,
      ),
    );

    try {
      if (isSupabaseConfigured && !widget.appContext.isDemo) {
        await repository.createMediaAsset(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto registrada')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class DailyReportFormScreen extends StatefulWidget {
  const DailyReportFormScreen({
    super.key,
    required this.appContext,
    required this.child,
  });

  final AppContextData appContext;
  final ChildSummary child;

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
  void initState() {
    super.initState();
    _centerId.text = widget.appContext.centerId;
    _childId.text = widget.child.id;
  }

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
      appBar: AppBar(title: Text('Agenda de ${widget.child.fullName}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            HeaderBlock(
              title: widget.child.fullName,
              subtitle: 'Registro diario',
              metric: 'Martes 15 de septiembre',
              icon: Icons.edit_note_outlined,
            ),
            if (isSupabaseConfigured && widget.appContext.isDemo)
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
        final payload = DailyReportPayloadBuilder.fromSchoolDraft(
          SchoolDailyReportDraft(
            centerId: _centerId.text,
            childId: _childId.text,
            reportDate: _reportDate.text,
            breakfast: _breakfast,
            lunch: _lunch,
            snack: _snack,
            morningPoop: _morningPoop,
            afternoonPoop: _afternoonPoop,
            morningSleep: _morningSleep,
            morningSleepTime: _morningSleepTime.text,
            afternoonSleep: _afternoonSleep,
            afternoonSleepTime: _afternoonSleepTime.text,
            schoolNotes: _schoolNotes.text,
            homeNotes: _homeNotes.text,
            medication: _medication.text,
            userId: Supabase.instance.client.auth.currentUser?.id,
          ),
        );

        await Supabase.instance.client
            .from('daily_reports')
            .upsert(payload, onConflict: 'child_id,report_date');
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

class HomeReportFormScreen extends StatefulWidget {
  const HomeReportFormScreen({
    super.key,
    required this.appContext,
    required this.child,
  });

  final AppContextData appContext;
  final ChildSummary child;

  @override
  State<HomeReportFormScreen> createState() => _HomeReportFormScreenState();
}

class _HomeReportFormScreenState extends State<HomeReportFormScreen> {
  final _centerId = TextEditingController();
  final _childId = TextEditingController();
  final _reportDate = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  String _sleep = 'Bien';
  String _breakfast = 'Si';
  String _bowelMovement = 'No';
  final _homeNotes = TextEditingController();
  final _medication = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _centerId.text = widget.appContext.centerId;
    _childId.text = widget.child.id;
  }

  @override
  void dispose() {
    _centerId.dispose();
    _childId.dispose();
    _reportDate.dispose();
    _homeNotes.dispose();
    _medication.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informacion de casa')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            HeaderBlock(
              title: widget.child.fullName,
              subtitle: 'Antes de llegar',
              metric: 'Informacion para la escuela',
              icon: Icons.home_work_outlined,
            ),
            if (isSupabaseConfigured && widget.appContext.isDemo)
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
              title: 'Esta manana',
              children: [
                ChoiceLine(
                  label: 'Como ha dormido',
                  value: _sleep,
                  options: const ['Bien', 'Regular', 'Mal'],
                  onChanged: (value) => setState(() => _sleep = value),
                ),
                ChoiceLine(
                  label: 'Ha desayunado',
                  value: _breakfast,
                  options: const ['Si', 'No'],
                  onChanged: (value) => setState(() => _breakfast = value),
                ),
                ChoiceLine(
                  label: 'Deposicion en casa',
                  value: _bowelMovement,
                  options: const ['Si', 'No'],
                  onChanged: (value) => setState(() => _bowelMovement = value),
                ),
              ],
            ),
            FormSection(
              title: 'Notas para hoy',
              children: [
                AppTextField(
                  controller: _homeNotes,
                  label: 'Observaciones de casa',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                AppTextField(
                  controller: _medication,
                  label: 'Medicacion',
                  icon: Icons.medication_outlined,
                  maxLines: 3,
                ),
              ],
            ),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_submitting ? 'Enviando' : 'Enviar a la escuela'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    if (isSupabaseConfigured) {
      final missing = requiredField(_centerId.text) ??
          requiredField(_childId.text) ??
          birthDateField(_reportDate.text);
      if (missing != null) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(missing)),
        );
        return;
      }

      try {
        final payload = DailyReportPayloadBuilder.fromHomeDraft(
          HomeDailyReportDraft(
            centerId: _centerId.text,
            childId: _childId.text,
            reportDate: _reportDate.text,
            sleep: _sleep,
            breakfast: _breakfast,
            bowelMovement: _bowelMovement,
            homeNotes: _homeNotes.text,
            medication: _medication.text,
            userId: Supabase.instance.client.auth.currentUser?.id,
          ),
        );

        await Supabase.instance.client
            .from('daily_reports')
            .upsert(payload, onConflict: 'child_id,report_date');
      } catch (error) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informacion enviada')),
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
  const EnrollmentFormScreen({super.key, required this.appContext});

  final AppContextData appContext;

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
  void initState() {
    super.initState();
    _centerId.text = widget.appContext.centerId;
  }

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
              if (widget.appContext.isDemo)
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
                )
              else
                FormSection(
                  title: 'Centro',
                  children: [
                    InfoTile(
                      title: widget.appContext.centerName,
                      value: 'Centro seleccionado',
                      icon: Icons.apartment_outlined,
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

    final payload = EnrollmentPayloadBuilder.fromDraft(
      EnrollmentDraft(
        centerId: _centerId.text,
        classroomId: _classroomId.text,
        childFullName: _childName.text,
        birthDate: _birthDate.text,
        sex: _sex,
        allergies: _allergies.text,
        medicalNotes: _medicalNotes.text,
        notes: _notes.text,
        emergencyContactName: _emergencyName.text,
        emergencyContactPhone: _emergencyPhone.text,
        fatherName: _fatherName.text,
        fatherEmail: _fatherEmail.text,
        fatherPhone: _fatherPhone.text,
        motherName: _motherName.text,
        motherEmail: _motherEmail.text,
        motherPhone: _motherPhone.text,
        educatorName: _educatorName.text,
        educatorEmail: _educatorEmail.text,
      ),
    );

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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NidoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NidoColors.ink, Color(0xFF243B72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 30, color: NidoColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFC8D2EA),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFE6EBF8),
                      ),
                ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NidoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: NidoColors.primary, size: 22),
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
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NidoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFFFE8EE),
                child: Icon(Icons.notes_outlined,
                    size: 18, color: NidoColors.blush),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: NidoColors.ink,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
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
    return ActionChip(
      onPressed: onPressed,
      avatar: Icon(icon, size: 18, color: NidoColors.primary),
      label: Text(label),
      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
      backgroundColor: Colors.white,
      side: const BorderSide(color: NidoColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
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
    return Chip(
      avatar: Icon(icon, size: 18, color: NidoColors.primary),
      label: Text(label),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      backgroundColor: Colors.white,
      side: const BorderSide(color: NidoColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
