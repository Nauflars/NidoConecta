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
      home: const HomeShell(),
    );
  }
}

enum AppRole { family, educator, admin }

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
    return const Column(
      key: ValueKey('family'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderBlock(
          title: 'Mateo',
          subtitle: 'Hoy, martes 15 de septiembre',
          metric: 'En la escuela desde 08:37',
          icon: Icons.child_care,
        ),
        SizedBox(height: 12),
        DailyGrid(),
        SizedBox(height: 12),
        NoteCard(
          title: 'Observación de la educadora',
          text:
              'Hoy ha participado mucho en pintura y ha estado tranquilo durante la siesta.',
        ),
        SizedBox(height: 12),
        NoteCard(
          title: 'Casa',
          text: 'Ha dormido regular y ha desayunado poco.',
        ),
        SizedBox(height: 16),
        PrimaryActionButton(
          label: 'Enviar mensaje',
          icon: Icons.chat_bubble_outline,
        ),
      ],
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
        const PrimaryActionButton(
          label: 'Publicar comunicado',
          icon: Icons.campaign_outlined,
        ),
      ],
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
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: () {},
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
