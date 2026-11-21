import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../features/missions/domain/mission.dart';
import '../features/missions/presentation/app_cubit.dart';
import '../features/reports/export_report.dart';

const ink = Color(0xff173d31),
    green = Color(0xff286247),
    canvas = Color(0xfff4f5ef),
    muted = Color(0xff728078),
    amber = Color(0xffa46718);
Color severityColor(Severity s) => switch (s) {
  Severity.healthy => const Color(0xff438c61),
  Severity.low => const Color(0xffd3b437),
  Severity.moderate => const Color(0xffd88b38),
  Severity.high => const Color(0xffba5c51),
};
String title(String value) => value.replaceAll('_', ' ');

class FaddanApp extends StatelessWidget {
  const FaddanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'FADDAN | Field companion',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        surface: Colors.white,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    home: BlocBuilder<AppCubit, AppState>(
      builder: (context, state) =>
          state.role == null ? const Welcome() : const Shell(),
    ),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.light = false});
  final bool light;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.eco_rounded, color: light ? Colors.white : green, size: 32),
      const SizedBox(width: 8),
      Text(
        'FADDAN',
        style: TextStyle(
          fontSize: 25,
          letterSpacing: 3,
          fontWeight: FontWeight.w800,
          color: light ? Colors.white : ink,
        ),
      ),
    ],
  );
}

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  UserRole role = UserRole.owner;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Brand(),
                const SizedBox(height: 45),
                const Pill('SUPERVISED FIELD RESEARCH', color: green),
                const SizedBox(height: 20),
                Text(
                  'Every row.\nA clearer picture.',
                  style: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(fontSize: 43, height: 1.1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your field companion for mission insights, crop observations and careful human review.',
                  style: TextStyle(fontSize: 16, color: muted, height: 1.6),
                ),
                const SizedBox(height: 26),
                const Notice(
                  'Interactive prototype. All farms, readings and treatments are simulated. No live robot or backend is connected.',
                ),
                const SizedBox(height: 26),
                const Text(
                  'EXPLORE AS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w700,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 10),
                ...UserRole.values.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: r == role ? const Color(0xffe4eddf) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: Icon(
                          r == role
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: green,
                        ),
                        onTap: () => setState(() => role = r),
                        title: Text(r.label),
                        subtitle: Text(switch (r) {
                          UserRole.owner =>
                            'Farm insights, heatmaps and reports',
                          UserRole.operator =>
                            'Mission monitoring and field status',
                          UserRole.agronomist =>
                            'Inspect observations and save review drafts',
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.read<AppCubit>().login(role),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Enter demo workspace'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No credentials required. Role selection is for demonstration only, not real authentication.',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  final labels = ['Overview', 'Missions', 'Review', 'Reports', 'Settings'];
  final icons = [
    Icons.grid_view_rounded,
    Icons.route_rounded,
    Icons.fact_check_outlined,
    Icons.assessment_outlined,
    Icons.tune_rounded,
  ];
  @override
  Widget build(BuildContext context) => BlocBuilder<AppCubit, AppState>(
    builder: (context, s) {
      final wide = MediaQuery.sizeOf(context).width > 1000;
      final pages = [
        Overview(onMissions: () => setState(() => index = 1)),
        const MissionsPage(),
        const ReviewPage(),
        const ReportsPage(),
        const SettingsPage(),
      ];
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              if (wide)
                Container(
                  width: 218,
                  color: ink,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Brand(light: true),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(26, 10, 20, 24),
                        child: Text(
                          'FIELD COMPANION',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      ...List.generate(
                        5,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tileColor: index == i
                                  ? Colors.white12
                                  : Colors.transparent,
                              leading: Icon(
                                icons[i],
                                color: index == i
                                    ? const Color(0xffcadca4)
                                    : Colors.white60,
                              ),
                              title: Text(
                                labels[i],
                                style: TextStyle(
                                  color: index == i
                                      ? Colors.white
                                      : Colors.white60,
                                ),
                              ),
                              onTap: () => setState(() => index = i),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'WATER-TRIAL MVP\nHuman judgment first.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 32 : 18,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xffe6e9e1)),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (!wide)
                            const Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Brand(),
                                ),
                              ),
                            ),
                          if (wide)
                            Expanded(
                              child: Text(
                                'Workspace / ${labels[index]}',
                                style: const TextStyle(color: muted),
                              ),
                            ),
                          Pill(
                            s.offline ? 'OFFLINE DEMO' : 'DEMO DATA',
                            color: s.offline ? amber : green,
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            tooltip: 'Sign out of demo',
                            onPressed: () => context.read<AppCubit>().logout(),
                            icon: const Icon(Icons.logout, size: 20),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(wide ? 32 : 18),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1160),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (s.error != null) ...[
                                  Notice(s.error!),
                                  const SizedBox(height: 16),
                                ],
                                pages[index],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                destinations: List.generate(
                  5,
                  (i) => NavigationDestination(
                    icon: Icon(icons[i]),
                    label: labels[i],
                  ),
                ),
              ),
      );
    },
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(
    this.eyebrow,
    this.heading,
    this.subtitle, {
    super.key,
    this.action,
  });
  final String eyebrow, heading, subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: muted,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(heading, style: Theme.of(context).textTheme.headlineLarge),
            ?action,
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: muted)),
      ],
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = 22,
    this.color = Colors.white,
  });
  final Widget child;
  final double padding;
  final Color color;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xffe5e8de)),
    ),
    child: Padding(padding: EdgeInsets.all(padding), child: child),
  );
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = green});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        letterSpacing: .7,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class Notice extends StatelessWidget {
  const Notice(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xfff5eddb),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 18, color: amber),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xff7c5a25),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class Metrics extends StatelessWidget {
  const Metrics({super.key, required this.items});
  final List<(String, String, String, IconData)> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth > 800 ? 4 : 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items
            .map(
              (m) => SizedBox(
                width: (c.maxWidth - 12 * (cols - 1)) / cols,
                child: Panel(
                  padding: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(m.$4, color: green, size: 20),
                          const Spacer(),
                          const Icon(Icons.north_east, size: 14, color: muted),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          m.$2,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        m.$3,
                        style: const TextStyle(fontSize: 10, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class Overview extends StatelessWidget {
  const Overview({super.key, required this.onMissions});
  final VoidCallback onMissions;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppCubit>().state;
    final m = s.missions;
    if (m.isEmpty) {
      return const Notice(
        'No cached missions yet. Use Settings to reload the demo.',
      );
    }
    final pending = m
        .expand((m) => m.points)
        .where((d) => d.needsReview && !s.reviews.containsKey(d.id))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          'Field intelligence',
          'A good view of your field.',
          '${s.role?.label} workspace. Readings below are saved sample observations, not live telemetry.',
          action: OutlinedButton.icon(
            onPressed: s.loading
                ? null
                : () => context.read<AppCubit>().refresh(),
            icon: const Icon(Icons.sync, size: 16),
            label: Text(s.loading ? 'Saving…' : 'Reload demo'),
          ),
        ),
        Panel(
          color: const Color(0xffe7eddf),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Pill('RESEARCH MODE'),
                    const SizedBox(height: 14),
                    Text(
                      'Small observations.\nBetter field decisions.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Explore row coverage and disease pressure.\nKeep every treatment under human supervision.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: onMissions,
                      child: const Text('Explore missions  →'),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width >= 360) ...[
                const SizedBox(width: 10),
                const SizedBox(
                  width: 95,
                  height: 135,
                  child: CustomPaint(painter: LeafPainter()),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Metrics(
          items: [
            (
              'Sample missions',
              '${m.length}',
              '2 illustrative farms',
              Icons.route,
            ),
            (
              'Rows inspected',
              '${m.where((x) => x.progress == 1).length}',
              'Saved fixture records',
              Icons.grass,
            ),
            (
              'Awaiting review',
              '$pending',
              'Local demo queue',
              Icons.fact_check_outlined,
            ),
            (
              'Liquid reduction',
              '${m.first.savings?.toStringAsFixed(0)}%',
              'Example vs blanket baseline',
              Icons.water_drop_outlined,
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent missions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(onPressed: onMissions, child: const Text('View all →')),
          ],
        ),
        const SizedBox(height: 10),
        ...m.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MissionTile(m),
          ),
        ),
        const SizedBox(height: 10),
        CacheFooter(s),
        const SizedBox(height: 14),
        const Notice(
          'Academic MVP: supervised water trials. No automatic pesticide dosing, live robot control or export certification is enabled.',
        ),
      ],
    );
  }
}

class CacheFooter extends StatelessWidget {
  const CacheFooter(this.s, {super.key});
  final AppState s;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        s.offline ? Icons.cloud_off_outlined : Icons.inventory_2_outlined,
        size: 15,
        color: muted,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Saved on this device${s.cachedAt == null ? '' : ' • ${DateFormat('dd MMM, HH:mm').format(s.cachedAt!.toLocal())} local'} • Fixture capture: 21 Nov 2026',
          style: const TextStyle(fontSize: 10, color: muted),
        ),
      ),
    ],
  );
}

class MissionTile extends StatelessWidget {
  const MissionTile(this.m, {super.key});
  final Mission m;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => MissionDetail(m)),
    ),
    child: Panel(
      padding: 17,
      child: Row(
        children: [
          if (MediaQuery.sizeOf(context).width >= 360) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffedf1e7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grass, color: green),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.farmName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Greenhouse ${m.greenhouseId} · Row ${m.row}',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: m.progress,
                    minHeight: 4,
                    color: green,
                    backgroundColor: const Color(0xffe9ecdf),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Pill(
                m.progress == 1 ? 'COMPLETE' : 'PARTIAL',
                color: m.progress == 1 ? green : amber,
              ),
              const SizedBox(height: 8),
              Text(
                '${(m.progress * 100).toInt()}% coverage',
                style: const TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: muted),
        ],
      ),
    ),
  );
}

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});
  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  String query = '';
  int filter = 0;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppCubit>().state;
    final rows = s.missions
        .where(
          (m) =>
              (filter == 0 || m.farmId == (filter == 1 ? 101 : 202)) &&
              ('${m.farmName} ${m.row}'.toLowerCase().contains(
                query.toLowerCase(),
              )),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'Mission library',
          'Every pass, recorded.',
          'Browse saved research missions by farm and row.',
        ),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search farm or row',
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i < 3; i++)
              ChoiceChip(
                label: Text(['All farms', 'Nubaria', 'Sadat'][i]),
                selected: filter == i,
                onSelected: (_) => setState(() => filter = i),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (rows.isEmpty)
          const Panel(child: Text('No missions match this search.')),
        ...rows.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MissionTile(m),
          ),
        ),
        const SizedBox(height: 18),
        const Notice(
          'Starting, pausing or aborting a real robot is intentionally unavailable. A verified backend and acknowledged, expiring command contract are required.',
        ),
      ],
    );
  }
}

class MissionDetail extends StatefulWidget {
  const MissionDetail(this.m, {super.key});
  final Mission m;
  @override
  State<MissionDetail> createState() => _MissionDetailState();
}

class _MissionDetailState extends State<MissionDetail> {
  int layer = 1;
  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    return Scaffold(
      appBar: AppBar(title: Text('Row ${m.row} / Mission detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeading(
                  m.farmName,
                  'A closer look at row ${m.row}.',
                  'Greenhouse ${m.greenhouseId} • ${DateFormat('dd MMM yyyy, HH:mm').format(m.started.toLocal())} local • DEMO',
                ),
                Metrics(
                  items: [
                    (
                      'Battery',
                      '${m.battery?.toStringAsFixed(0) ?? '—'}%',
                      'Saved sample, not live',
                      Icons.battery_5_bar,
                    ),
                    (
                      'Tank',
                      '${m.tank?.toStringAsFixed(0) ?? '—'} mL',
                      'Simulated water',
                      Icons.water_drop_outlined,
                    ),
                    (
                      'Temperature',
                      '${m.temperature?.toStringAsFixed(1) ?? '—'}°C',
                      'Sample average',
                      Icons.thermostat,
                    ),
                    (
                      'Humidity',
                      '${m.humidity?.toStringAsFixed(1) ?? '—'}%',
                      'Sample average',
                      Icons.air,
                    ),
                  ],
                ),
                if ((m.battery ?? 100) < 20) ...[
                  const SizedBox(height: 14),
                  const Notice(
                    'Sample battery is below 20%. This demonstrates an alert, not a current hardware warning.',
                  ),
                ],
                const SizedBox(height: 24),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Three layers. One crop row.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Position is relative to the row start, in centimetres.',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (int i = 0; i < 3; i++)
                            ChoiceChip(
                              label: Text(
                                [
                                  'Coverage',
                                  'Disease pressure',
                                  'As-applied / PHI',
                                ][i],
                              ),
                              selected: layer == i,
                              onSelected: (_) => setState(() => layer = i),
                            ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: CustomPaint(painter: RowPainter(m, layer)),
                      ),
                      const SizedBox(height: 10),
                      if (layer == 1)
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: Severity.values
                              .map(
                                (s) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 9,
                                      color: severityColor(s),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      switch (s) {
                                        Severity.healthy => 'Healthy 0%',
                                        Severity.low => 'Low <15%',
                                        Severity.moderate => 'Moderate 15–40%',
                                        Severity.high => 'High >40%',
                                      },
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: muted,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      if (layer == 0)
                        Text(
                          '${m.covered.toStringAsFixed(0)} / ${m.length.toStringAsFixed(0)} cm inspected. Uninspected distance remains blank.',
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                      if (layer == 2)
                        const Text(
                          'Water-trial records only. No pesticide or safe-harvest date is available.',
                          style: TextStyle(fontSize: 12, color: amber),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Observations along this row',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...m.points.map((d) => DetectionTile(d, m)),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => exportMission(m),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Preview / export demo report'),
                ),
                const SizedBox(height: 14),
                const Notice(
                  'No motion or spray control is available in this demo. A review draft never triggers a robot action.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RowPainter extends CustomPainter {
  RowPainter(this.m, this.layer);
  final Mission m;
  final int layer;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint();
    final y = s.height * .48;
    final w = s.width - 32;
    const x = 16.0;
    p.color = const Color(0xffe4e7dc);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y - 19, w, 38),
        const Radius.circular(9),
      ),
      p,
    );
    p.color = const Color(0xffbed0a7);
    if (layer == 0) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y - 19, w * m.progress, 38),
          const Radius.circular(9),
        ),
        p,
      );
    }
    for (final d in m.points) {
      final dx =
          x + (m.length <= 0 ? 0 : (d.distance / m.length).clamp(0, 1)) * w;
      p.color = layer == 0
          ? green
          : layer == 1
          ? severityColor(d.severity)
          : d.sprayed
          ? green
          : Colors.grey;
      final r = layer == 2 ? (d.sprayed ? 11.0 : 6.0) : 9.0;
      c.drawCircle(Offset(dx, y), r, p);
      if (layer == 2 && d.sprayed) {
        _text(
          c,
          '${d.dosage} mL',
          Offset((dx - 17).clamp(0, s.width - 40), y - 46),
          10,
          green,
        );
      }
      if (d.needsReview && layer == 1) {
        p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ink;
        c.drawCircle(Offset(dx, y), 13, p);
        p.style = PaintingStyle.fill;
      }
    }
    _text(c, 'START', Offset(x, y + 36), 10, muted);
    _text(
      c,
      '${m.length.toStringAsFixed(0)} cm',
      Offset(s.width - 66, y + 36),
      10,
      muted,
    );
    _text(c, 'Row ${m.row}', const Offset(16, 1), 12, ink);
  }

  void _text(Canvas c, String t, Offset o, double n, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          fontSize: n,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(c, o);
  }

  @override
  bool shouldRepaint(covariant RowPainter old) =>
      old.layer != layer || old.m != m;
}

class LeafPainter extends CustomPainter {
  const LeafPainter();
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = green.withValues(alpha: .9);
    final path = Path()
      ..moveTo(s.width * .45, s.height * .88)
      ..cubicTo(
        -s.width * .2,
        s.height * .45,
        s.width * .22,
        s.height * .08,
        s.width * .83,
        0,
      )
      ..cubicTo(
        s.width * 1.1,
        s.height * .6,
        s.width * .8,
        s.height * .85,
        s.width * .45,
        s.height * .88,
      );
    c.drawPath(path, p);
    p
      ..color = const Color(0xffb9d296)
      ..strokeWidth = 2;
    c.drawLine(
      Offset(s.width * .4, s.height),
      Offset(s.width * .7, s.height * .17),
      p,
    );
    for (int i = 1; i < 5; i++) {
      final y = s.height * (.25 + i * .12);
      c.drawLine(
        Offset(s.width * (.7 - i * .05), y),
        Offset(s.width * .25, y - .14 * s.height),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class DetectionTile extends StatelessWidget {
  const DetectionTile(this.d, this.m, {super.key});
  final Detection d;
  final Mission m;
  @override
  Widget build(BuildContext context) {
    final review = context.watch<AppCubit>().state.reviews[d.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => DetectionDetail(d, m)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Panel(
          padding: 15,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 36,
                decoration: BoxDecoration(
                  color: severityColor(d.severity),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title(d.disease),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'GH ${m.greenhouseId} / Row ${m.row} · ${d.distance.toStringAsFixed(0)} cm\n${d.infection.toStringAsFixed(1)}% affected',
                      style: const TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
              if (review != null)
                const Pill('DRAFT SAVED')
              else if (d.needsReview)
                const Pill('REVIEW', color: amber)
              else
                Text(
                  '${(d.confidence * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
              const Icon(Icons.chevron_right, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppCubit>().state;
    final ds = [
      for (final m in s.missions)
        for (final d in m.points)
          if (d.needsReview) (d, m),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'Human in the loop',
          'A second pair of eyes.',
          'Uncertain model results need expert review. Nothing is sent to a server.',
        ),
        if (s.role != UserRole.agronomist) ...[
          const Notice(
            'Read-only preview. To try local review drafts, sign out and enter as Agronomist.',
          ),
          const SizedBox(height: 18),
        ],
        const Notice(
          'All review decisions are local demo drafts. Approving an observation does not authorize or execute treatment.',
        ),
        const SizedBox(height: 20),
        ...ds.map((x) => DetectionTile(x.$1, x.$2)),
        if (ds.isEmpty)
          const Panel(child: Text('No observations in the review queue.')),
      ],
    );
  }
}

class DetectionDetail extends StatelessWidget {
  const DetectionDetail(this.d, this.m, {super.key});
  final Detection d;
  final Mission m;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppCubit>().state;
    final draft = s.reviews[d.id];
    return Scaffold(
      appBar: AppBar(title: const Text('Observation detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeading(
                  'Row ${m.row} / ${d.distance.toStringAsFixed(0)} cm',
                  title(d.disease),
                  'SIMULATED OBSERVATION • ${d.id}',
                ),
                Panel(
                  color: const Color(0xffe7eddf),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 110,
                        height: 140,
                        child: CustomPaint(painter: LeafPainter()),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Illustration, not a diagnostic image',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'No leaf photograph was supplied for this fixture.',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Metrics(
                  items: [
                    (
                      'Affected leaf area',
                      '${d.infection.toStringAsFixed(1)}%',
                      'Simulated severity',
                      Icons.eco_outlined,
                    ),
                    (
                      'Model confidence',
                      '${(d.confidence * 100).toStringAsFixed(0)}%',
                      'Not a safety guarantee',
                      Icons.analytics_outlined,
                    ),
                    (
                      'Applied volume',
                      '${d.dosage} mL',
                      'Simulated water',
                      Icons.water_drop_outlined,
                    ),
                    (
                      'Execution',
                      d.sprayed ? 'Recorded' : 'Not sprayed',
                      'Fixture state only',
                      Icons.check_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Notice(
                  'Pesticide and harvest date: not applicable to the water-trial demo. Diagnosis and dosing require qualified agronomic validation.',
                ),
                if (d.needsReview) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Agronomist review',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (draft != null)
                    Panel(child: Text('Saved locally: $draft. Not submitted.')),
                  ...[
                    const SizedBox(height: 12),
                    Text(
                      'Suggested label: ${title(d.disease)}. Use the review form to confirm or correct this sample.',
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: s.role == UserRole.agronomist
                          ? () => _review(context, d)
                          : null,
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Create local review draft'),
                    ),
                  ],
                ],
                const SizedBox(height: 18),
                const Text(
                  'No treatment command is created by this page.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _review(BuildContext context, Detection d) async {
    String disease = d.disease;
    String decision = 'Approve label';
    bool include = false;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('Local review draft'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Notice(
                  'Demo only. This form does not prescribe a dose or contact the robot.',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: decision,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Review decision',
                  ),
                  items:
                      ['Approve label', 'Reject label', 'Needs more evidence']
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                  onChanged: (v) => set(() => decision = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: disease,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmed disease',
                  ),
                  items:
                      [
                            'Gray_Mold',
                            'Powdery_Mildew',
                            'Leaf_Spot',
                            'Spider_Mites',
                            'Healthy',
                            'Uncertain',
                          ]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(title(v)),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => set(() => disease = v!),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Flag for dataset review',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: include,
                  onChanged: (v) => set(() => include = v!),
                ),
                const Text(
                  'No image or data is uploaded. The flag is a local demonstration.',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                '$decision · ${title(disease)}${include ? ' · dataset review requested' : ''}',
              ),
              child: const Text('Save draft'),
            ),
          ],
        ),
      ),
    );
    if (result != null && context.mounted) {
      await context.read<AppCubit>().review(d.id, result);
    }
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'Treatment records',
          'Evidence, not promises.',
          'Preview a traceable demonstration report for each mission.',
        ),
        const Notice(
          'Reports contain simulated water-trial data. They are not pesticide advice, measured ROI or export certification.',
        ),
        const SizedBox(height: 22),
        ...s.missions.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${m.farmName} · Row ${m.row}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${m.actualMl} mL simulated water / ${m.baselineMl} mL illustrative reference',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: ((m.savings ?? 0) / 100).clamp(0, 1),
                    color: green,
                    backgroundColor: const Color(0xffe6eadd),
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${m.savings?.toStringAsFixed(1) ?? '—'}% illustrative liquid reduction',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monetary ROI and safe-harvest date are unavailable.',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => exportMission(m),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Preview / export PDF'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'Workspace settings',
          'Clear about what is real.',
          'Build 0.1.0 • Flutter prototype • No live integration',
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offline-first demonstration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Simulate loss of internet'),
                subtitle: const Text(
                  'Read saved missions and create local review drafts.',
                ),
                value: s.offline,
                onChanged: (v) => context.read<AppCubit>().setOffline(v),
              ),
              const SizedBox(height: 12),
              CacheFooter(s),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: s.offline
                    ? null
                    : () => context.read<AppCubit>().refresh(),
                icon: const Icon(Icons.sync),
                label: const Text('Reload fixture data'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assumptions in this version',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...[
                'English-first prototype. Arabic/RTL is a planned next step, not implemented.',
                'Farm names, dates, missions and readings are fictional fixtures.',
                'Role selection is demo navigation, not secure sign-in.',
                'REST adapter follows the guide’s /api/v1 summary route, but is not connected.',
                'Only supervised water-trial reporting is demonstrated.',
                'No real motion, spray, pesticide selection or delayed command replay.',
                'Local review drafts persist on this device and are not submitted.',
                'No real leaf photos, live telemetry, safe-harvest calculation or certification.',
              ].map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: TextStyle(color: green)),
                      Expanded(
                        child: Text(
                          t,
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () async {
            final yes = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Reset local demo data?'),
                content: const Text(
                  'This removes review drafts and saved demo settings on this device.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
            if (yes == true && context.mounted) {
              await context.read<AppCubit>().reset();
            }
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset demo and review drafts'),
        ),
      ],
    );
  }
}
