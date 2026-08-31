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
          primary: NidoColors.primary,
          secondary: NidoColors.sage,
          surface: NidoColors.surface,
          error: NidoColors.danger,
        ),
        scaffoldBackgroundColor: NidoColors.canvas,
        useMaterial3: true,
        fontFamily: 'Fira Sans',
        fontFamilyFallback: const ['Segoe UI', 'Roboto', 'Arial'],
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: NidoColors.surface,
          foregroundColor: NidoColors.ink,
          titleTextStyle: TextStyle(
            color: NidoColors.ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        cardTheme: CardTheme(
          color: NidoColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: NidoColors.line),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: NidoColors.surface,
          prefixIconColor: NidoColors.sage,
          labelStyle: const TextStyle(color: NidoColors.muted),
          floatingLabelStyle: const TextStyle(
            color: NidoColors.primary,
            fontWeight: FontWeight.w800,
          ),
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
            borderSide: const BorderSide(color: NidoColors.sage, width: 1.4),
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
            minimumSize: const Size(48, 48),
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
  static const primary = Color(0xFF3157D5);
  static const ink = Color(0xFF101828);
  static const muted = Color(0xFF667085);
  static const canvas = Color(0xFFF7F8F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceWarm = Color(0xFFFFF7E8);
  static const line = Color(0xFFE0E7DF);
  static const blush = Color(0xFFE95872);
  static const sage = Color(0xFF1E7A5F);
  static const mint = Color(0xFF2FB184);
  static const amber = Color(0xFFD9822B);
  static const sky = Color(0xFF3B82F6);
  static const danger = Color(0xFFB42318);
  static const lavender = Color(0xFFEDEBFF);
}

class NidoShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x14101828),
      blurRadius: 28,
      offset: Offset(0, 16),
    ),
  ];

  static const tight = [
    BoxShadow(
      color: Color(0x0F101828),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [NidoColors.canvas, Color(0xFFEFF5F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 820;
                  final form = LoginFormPanel(
                    email: _email,
                    password: _password,
                    loading: _loading,
                    onSignIn: _signIn,
                    onResetPassword: _resetPassword,
                  );

                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 28 : 20,
                      wide ? 42 : 24,
                      wide ? 28 : 20,
                      32,
                    ),
                    children: [
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: LoginBrandPanel()),
                            const SizedBox(width: 28),
                            SizedBox(width: 430, child: form),
                          ],
                        )
                      else ...[
                        const LoginBrandPanel(compact: true),
                        const SizedBox(height: 18),
                        form,
                      ],
                    ],
                  );
                },
              ),
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

class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 28),
      decoration: BoxDecoration(
        color: NidoColors.ink,
        borderRadius: BorderRadius.circular(8),
        boxShadow: NidoShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(size: 52),
          SizedBox(height: compact ? 20 : 46),
          Text(
            'NidoConecta',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'La agenda viva del centro: aulas, familias y direccion en el mismo lugar.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFE6EDE8),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              LoginProofLine(
                icon: Icons.verified_user_outlined,
                label: 'Acceso por rol',
              ),
              LoginProofLine(
                icon: Icons.insights_outlined,
                label: 'Historial real',
              ),
              LoginProofLine(
                icon: Icons.mail_outline,
                label: 'Familias avisadas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginProofLine extends StatelessWidget {
  const LoginProofLine({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17, color: Colors.white),
      label: Text(label),
      labelStyle: const TextStyle(
        color: NidoColors.surface,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: Colors.white.withOpacity(0.12),
      side: BorderSide(color: Colors.white.withOpacity(0.16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class LoginFormPanel extends StatelessWidget {
  const LoginFormPanel({
    super.key,
    required this.email,
    required this.password,
    required this.loading,
    required this.onSignIn,
    required this.onResetPassword,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool loading;
  final VoidCallback onSignIn;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Entrar',
      subtitle: 'Usa el email que recibiste del centro.',
      children: [
        AppTextField(
          controller: email,
          label: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: emailField,
        ),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contrasena',
            prefixIcon: Icon(Icons.password_outlined),
          ),
        ),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: loading ? null : onSignIn,
            icon: loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_outlined),
            label: Text(loading ? 'Entrando...' : 'Entrar'),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: loading ? null : onResetPassword,
            icon: const Icon(Icons.lock_reset_outlined),
            label: const Text('Cambiar o recuperar contrasena'),
          ),
        ),
      ],
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
        surfaceTintColor: Colors.transparent,
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
                constraints: const BoxConstraints(maxWidth: 1120),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                  children: [
                    if (appContext.isDemo)
                      PremiumRoleSelector(selected: _role, onChanged: _setRole)
                    else
                      StatusPill(
                        label:
                            '${appContext.centerName} · ${roleLabel(selectedRole)}',
                        icon: Icons.verified_user_outlined,
                      ),
                    const SizedBox(height: 18),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
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
          colors: [NidoColors.primary, NidoColors.sage],
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

class PremiumRoleSelector extends StatelessWidget {
  const PremiumRoleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppRole selected;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: NidoColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: NidoShadows.tight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 520) {
            return Row(
              children: [
                Expanded(
                  child: RoleTab(
                    selected: selected == AppRole.family,
                    label: 'Familia',
                    icon: Icons.home_outlined,
                    onTap: () => onChanged(AppRole.family),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RoleTab(
                    selected: selected == AppRole.educator,
                    label: 'Educadora',
                    icon: Icons.groups_outlined,
                    onTap: () => onChanged(AppRole.educator),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RoleTab(
                    selected: selected == AppRole.admin,
                    label: 'Direccion',
                    icon: Icons.dashboard_outlined,
                    onTap: () => onChanged(AppRole.admin),
                  ),
                ),
              ],
            );
          }

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
                label: Text('Direccion'),
                icon: Icon(Icons.dashboard_outlined),
              ),
            ],
            selected: {selected},
            onSelectionChanged: (value) => onChanged(value.single),
            showSelectedIcon: false,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? NidoColors.ink
                    : Colors.transparent,
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Colors.white
                    : NidoColors.ink,
              ),
              side: const WidgetStatePropertyAll(
                BorderSide(color: Colors.transparent),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RoleTab extends StatelessWidget {
  const RoleTab({
    super.key,
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : NidoColors.ink;

    return Material(
      color: selected ? NidoColors.ink : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
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
                    AppModule(
                      'Historial',
                      Icons.insights_outlined,
                      HistoryInsightsScreen(
                        appContext: appContext,
                        role: NidoRole.family,
                      ),
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
        boxShadow: NidoShadows.tight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: NidoColors.surfaceWarm,
                child: Icon(Icons.restaurant_outlined, color: NidoColors.amber),
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
            AppModule(
              'Historial',
              Icons.insights_outlined,
              HistoryInsightsScreen(
                appContext: appContext,
                role: NidoRole.educator,
              ),
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
            AppModule(
              'Historial',
              Icons.insights_outlined,
              HistoryInsightsScreen(
                appContext: appContext,
                role: NidoRole.admin,
              ),
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
            'Ninos',
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
              childAspectRatio: columns == 3 ? 2.25 : 1.65,
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
        const gap = 12.0;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        final compact =
            MediaQuery.sizeOf(context).width < 1100 || tileWidth < 300;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          childAspectRatio: compact ? 2.6 : 2.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final module in modules)
              ModuleTile(module: module, compact: compact),
          ],
        );
      },
    );
  }
}

class ModuleTile extends StatelessWidget {
  const ModuleTile({super.key, required this.module, required this.compact});

  final AppModule module;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = nidoAccentFor(module.icon);

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: NidoShadows.tight,
      ),
      child: Material(
        color: NidoColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => openModule(context, module.screen),
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 16),
            child: compact
                ? Row(
                    children: [
                      ModuleIcon(icon: module.icon, color: accent, size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          module.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: NidoColors.muted,
                        size: 18,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ModuleIcon(icon: module.icon, color: accent),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward,
                            color: NidoColors.muted,
                            size: 20,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            moduleSubtitle(module.title),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: NidoColors.muted,
                                      height: 1.25,
                                    ),
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
}

class ModuleIcon extends StatelessWidget {
  const ModuleIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

String moduleSubtitle(String title) {
  return switch (title) {
    'Calendario' => 'Eventos, cierres y salidas.',
    'Menu' => 'Comidas y alergias al dia.',
    'Fotos' => 'Momentos listos para revisar.',
    'Autorizados' => 'Recogidas y permisos activos.',
    'Historial' => 'Tendencias y evolucion.',
    'Asistencia' => 'Entradas, salidas y ausencias.',
    'Agenda diaria' => 'Rutinas, descanso y cuidados.',
    'Mensajes' => 'Conversaciones del centro.',
    'Comunicados' => 'Avisos para familias.',
    'Altas' => 'Ninos, familias y accesos.',
    'Personal' => 'Educadoras y aulas asignadas.',
    'Aulas' => 'Ratios y organizacion diaria.',
    'Informes' => 'Seguimiento por centro y aula.',
    _ => 'Acceso rapido del centro.',
  };
}

Color nidoAccentFor(IconData icon) {
  return switch (icon) {
    Icons.restaurant ||
    Icons.restaurant_outlined ||
    Icons.restaurant_menu_outlined =>
      NidoColors.amber,
    Icons.child_care ||
    Icons.child_care_outlined ||
    Icons.groups_outlined ||
    Icons.family_restroom_outlined =>
      NidoColors.sage,
    Icons.event_outlined ||
    Icons.today_outlined ||
    Icons.calendar_today_outlined =>
      NidoColors.sky,
    Icons.photo_library_outlined ||
    Icons.camera_alt_outlined ||
    Icons.collections_outlined =>
      NidoColors.blush,
    Icons.insights_outlined ||
    Icons.bar_chart_outlined ||
    Icons.edit_note_outlined =>
      NidoColors.primary,
    _ => NidoColors.primary,
  };
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

class HistoryInsightsScreen extends StatelessWidget {
  const HistoryInsightsScreen({
    super.key,
    required this.appContext,
    required this.role,
  });

  final AppContextData appContext;
  final NidoRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            HeaderBlock(
              title: _historyTitle,
              subtitle: 'Historial y estadisticas',
              metric: 'Ultimos 60 dias',
              icon: Icons.insights_outlined,
            ),
            const SizedBox(height: 12),
            HistorySummaryLoader(appContext: appContext, role: role),
          ],
        ),
      ),
    );
  }

  String get _historyTitle {
    return switch (role) {
      NidoRole.admin => appContext.centerName,
      NidoRole.educator => appContext.selectedChild.classroomName,
      NidoRole.family => appContext.selectedChild.fullName,
    };
  }
}

class HistorySummaryLoader extends StatelessWidget {
  const HistorySummaryLoader({
    super.key,
    required this.appContext,
    required this.role,
  });

  final AppContextData appContext;
  final NidoRole role;

  @override
  Widget build(BuildContext context) {
    final repository = AppRepository(
      client: isSupabaseConfigured ? Supabase.instance.client : null,
    );

    return FutureBuilder<HistorySummaryData>(
      future: repository.loadHistorySummary(appContext),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return NoteCard(
            title: 'No se pudo cargar el historial',
            text: snapshot.error.toString(),
          );
        }

        final data = snapshot.data;
        if (data == null || data.reportsCount == 0) {
          return const NoteCard(
            title: 'Sin historial',
            text:
                'Todavia no hay registros suficientes para calcular metricas.',
          );
        }

        return HistorySummaryContent(data: data, role: role);
      },
    );
  }
}

class HistorySummaryContent extends StatelessWidget {
  const HistorySummaryContent(
      {super.key, required this.data, required this.role});

  final HistorySummaryData data;
  final NidoRole role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HistoryKpiGrid(data: data),
        const SizedBox(height: 12),
        TrendCard(data: data),
        const SizedBox(height: 12),
        if (role == NidoRole.admin) ...[
          ClassroomStatsList(classrooms: data.classrooms),
          const SizedBox(height: 12),
        ],
        ChildStatsList(children: data.children, role: role),
      ],
    );
  }
}

class HistoryKpiGrid extends StatelessWidget {
  const HistoryKpiGrid({super.key, required this.data});

  final HistorySummaryData data;

  @override
  Widget build(BuildContext context) {
    final items = [
      MetricItem(
        'Agendas',
        '${data.reportsCount}',
        Icons.edit_note_outlined,
      ),
      MetricItem(
        'Dias con datos',
        '${data.reportDays}',
        Icons.date_range_outlined,
      ),
      MetricItem(
        'Asistencia',
        _percent(data.attendanceRate),
        Icons.how_to_reg_outlined,
      ),
      MetricItem(
        'Comida',
        _percent(data.mealScore),
        Icons.restaurant_outlined,
      ),
      MetricItem(
        'Descanso',
        _percent(data.sleepRate),
        Icons.bedtime_outlined,
      ),
      MetricItem(
        'Interacciones',
        '${data.messagesCount + data.mediaCount}',
        Icons.forum_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: columns == 3 ? 1.9 : 1.25,
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

class TrendCard extends StatelessWidget {
  const TrendCard({super.key, required this.data});

  final HistorySummaryData data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.timeline.fold<int>(1, (max, day) {
      final value = day.reportsCount + day.attendanceCount;
      return value > max ? value : max;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NidoColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: NidoShadows.tight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEAF0FF),
                child: Icon(Icons.stacked_bar_chart,
                    size: 20, color: NidoColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Actividad reciente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Text(
                '${_shortDate(data.fromDate)} - ${_shortDate(data.toDate)}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: NidoColors.muted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in data.timeline) ...[
                  Expanded(child: HistoryDayBar(day: day, maxValue: maxValue)),
                  if (day != data.timeline.last) const SizedBox(width: 5),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryDayBar extends StatelessWidget {
  const HistoryDayBar({super.key, required this.day, required this.maxValue});

  final HistoryDayData day;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final value = day.reportsCount + day.attendanceCount;
    final heightFactor = value == 0 ? 0.08 : value / maxValue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor.clamp(0.08, 1).toDouble(),
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: day.messagesCount + day.mediaCount > 0
                      ? NidoColors.blush
                      : NidoColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${day.date.day}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: NidoColors.muted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class ClassroomStatsList extends StatelessWidget {
  const ClassroomStatsList({super.key, required this.classrooms});

  final List<ClassroomHistoryData> classrooms;

  @override
  Widget build(BuildContext context) {
    return StatsListCard(
      title: 'Aulas',
      icon: Icons.groups_outlined,
      children: [
        for (final classroom in classrooms)
          ProgressStatLine(
            title: classroom.name,
            subtitle:
                '${classroom.childrenCount} ninos · ${classroom.reportsCount} agendas',
            value: classroom.attendanceRate,
            trailing: _percent(classroom.attendanceRate),
          ),
      ],
    );
  }
}

class ChildStatsList extends StatelessWidget {
  const ChildStatsList({super.key, required this.children, required this.role});

  final List<ChildHistoryData> children;
  final NidoRole role;

  @override
  Widget build(BuildContext context) {
    return StatsListCard(
      title: role == NidoRole.family ? 'Evolucion del nino' : 'Alumnos',
      icon: Icons.child_care_outlined,
      children: [
        for (final child in children.take(role == NidoRole.family ? 3 : 8))
          ProgressStatLine(
            title: child.child.fullName,
            subtitle:
                '${child.child.classroomName} · ${child.reportsCount} agendas · ${child.lastNote}',
            value: child.mealScore,
            trailing: _percent(child.sleepRate),
          ),
      ],
    );
  }
}

class StatsListCard extends StatelessWidget {
  const StatsListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

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
              Icon(icon, color: NidoColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children.expand((child) => [child, const SizedBox(height: 10)]),
        ],
      ),
    );
  }
}

class ProgressStatLine extends StatelessWidget {
  const ProgressStatLine({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final double value;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Text(
              trailing,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: NidoColors.primary,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: NidoColors.muted,
              ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(),
            minHeight: 7,
            backgroundColor: const Color(0xFFEAF0FF),
            color: NidoColors.primary,
          ),
        ),
      ],
    );
  }
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

String _shortDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}';
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
  const FormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NidoColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: NidoShadows.tight,
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: NidoColors.muted,
                    height: 1.35,
                  ),
            ),
          ],
          const SizedBox(height: 14),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: NidoColors.ink,
        borderRadius: BorderRadius.circular(8),
        boxShadow: NidoShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: NidoColors.surfaceWarm,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 30, color: NidoColors.sage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFCFE5DA),
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
                        color: const Color(0xFFE6EDE8),
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
    final accent = nidoAccentFor(icon);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NidoColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: NidoShadows.tight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: NidoColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
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
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8EE),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: const Icon(Icons.notes_outlined,
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
      backgroundColor: NidoColors.surface,
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
          backgroundColor: NidoColors.ink,
          foregroundColor: Colors.white,
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
      backgroundColor: NidoColors.surface,
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
