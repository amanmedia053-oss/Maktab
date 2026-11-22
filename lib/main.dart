import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/local_database.dart';

const green = Color(0xFF174B3B);
const gold = Color(0xFFC49A52);
const cream = Color(0xFFF7F5EF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.database;
  final prefs = await SharedPreferences.getInstance();
  runApp(MaktabApp(dark: prefs.getBool('dark_mode') ?? false));
}

class MaktabApp extends StatefulWidget {
  const MaktabApp({super.key, required this.dark});
  final bool dark;
  @override
  State<MaktabApp> createState() => _MaktabAppState();
}

class _MaktabAppState extends State<MaktabApp> {
  late bool dark = widget.dark;
  Future<void> changeTheme(bool value) async {
    setState(() => dark = value);
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', value);
  }
  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(seedColor: green, brightness: dark ? Brightness.dark : Brightness.light);
    return MaterialApp(
      title: 'مکتب', debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorScheme: colors, scaffoldBackgroundColor: cream, appBarTheme: const AppBarTheme(backgroundColor: cream, foregroundColor: green, elevation: 0)),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: colors, scaffoldBackgroundColor: const Color(0xFF101915)),
      home: Directionality(textDirection: TextDirection.rtl, child: MainShell(dark: dark, onTheme: changeTheme)),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.dark, required this.onTheme});
  final bool dark;
  final ValueChanged<bool> onTheme;
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const Dashboard(), const ModulesPage(), const ReportsPage(), SettingsPage(dark: widget.dark, onTheme: widget.onTheme)];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), label: 'کور'),
        NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'برخې'),
        NavigationDestination(icon: Icon(Icons.insert_chart_outlined), label: 'راپورونه'),
        NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'تنظیمات'),
      ]),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final db = LocalDatabase.instance;
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 10), child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.school_rounded, color: Colors.white, size: 27)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مکتب', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: green)), Text('د ښوونځي د مدیریت سیستم', style: TextStyle(fontSize: 12, color: Colors.grey))])),
        const Icon(Icons.notifications_none_rounded, size: 26),
        const SizedBox(width: 10),
        const CircleAvatar(backgroundColor: Color(0xFFEDE3D0), child: Icon(Icons.person_outline, color: green)),
      ]))),
      SliverToBoxAdapter(child: Container(
        margin: const EdgeInsets.fromLTRB(20, 15, 20, 22), padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF205A45), Color(0xFF123B30)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: green.withOpacity(.18), blurRadius: 22, offset: const Offset(0, 9))]),
        child: Stack(children: [
          Positioned(left: 0, top: 0, child: Icon(Icons.auto_stories_rounded, size: 90, color: Colors.white.withOpacity(.07))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ښه راغلاست!', style: TextStyle(color: Color(0xFFE8D4A8), fontWeight: FontWeight.w700)),
            const SizedBox(height: 9),
            const Text('د مکتب ټول مدیریت،\nپه یوه ښکلي ځای کې.', style: TextStyle(color: Colors.white, fontSize: 24, height: 1.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 17),
            Row(children: [const Icon(Icons.calendar_month, color: Colors.white70, size: 17), const SizedBox(width: 7), const Text('تعلیمي کال: ۱۴۰۵', style: TextStyle(color: Colors.white70, fontSize: 12)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(30)), child: const Text('آفلاین سیستم', style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.bold)))]),
          ]),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [const Expanded(child: Text('د مکتب لنډیز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Text('احصایې', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 22), sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5),
        delegate: SliverChildListDelegate([
          StatCard(title: 'زده‌کوونکي', table: 'students', icon: Icons.school_outlined, db: db),
          StatCard(title: 'ښوونکي', table: 'teachers', icon: Icons.co_present_outlined, db: db),
          StatCard(title: 'ټولګي', table: 'classes', icon: Icons.meeting_room_outlined, db: db),
          StatCard(title: 'کتابونه', table: 'library', icon: Icons.menu_book_rounded, db: db),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: const Text('چټک لاسرسی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .98),
        delegate: SliverChildListDelegate([
          QuickTile(title: 'حاضري', icon: Icons.fact_check_outlined, table: 'attendance'),
          QuickTile(title: 'ازموینې', icon: Icons.assignment_outlined, table: 'exams'),
          QuickTile(title: 'مالي چارې', icon: Icons.account_balance_wallet_outlined, table: 'finance'),
          QuickTile(title: 'پایلې', icon: Icons.grade_outlined, table: 'results'),
          QuickTile(title: 'مهالوېش', icon: Icons.schedule_rounded, table: 'timetable'),
          QuickTile(title: 'کتابتون', icon: Icons.local_library_outlined, table: 'library'),
        ]),
      )),
    ]);
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.title, required this.table, required this.icon, required this.db});
  final String title, table; final IconData icon; final LocalDatabase db;
  @override
  Widget build(BuildContext context) => FutureBuilder<int>(
    future: db.count(table),
    builder: (context, snap) => Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color ?? Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFE4EFE8), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: green)),
        Text(snap.hasData ? '${snap.data}' : '—', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    ),
  );
}

class QuickTile extends StatelessWidget {
  const QuickTile({super.key, required this.title, required this.icon, required this.table});
  final String title, table; final IconData icon;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ModulePage(table: table, title: LocalDatabase.modules[table] ?? title))),
    child: Container(
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: green, size: 27), const SizedBox(height: 9), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]),
    ),
  );
}

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});
  static const icons = <String, IconData>{
    'students': Icons.school_outlined, 'teachers': Icons.co_present_outlined, 'classes': Icons.meeting_room_outlined,
    'subjects': Icons.menu_book_outlined, 'attendance': Icons.fact_check_outlined, 'exams': Icons.assignment_outlined,
    'results': Icons.grade_outlined, 'finance': Icons.account_balance_wallet_outlined, 'library': Icons.local_library_outlined,
    'timetable': Icons.schedule_rounded, 'staff': Icons.badge_outlined, 'parents': Icons.family_restroom_outlined,
    'notifications': Icons.notifications_none_rounded, 'documents': Icons.folder_open_outlined, 'certificates': Icons.workspace_premium_outlined,
    'holidays': Icons.event_available_outlined, 'reports': Icons.insert_chart_outlined, 'users': Icons.manage_accounts_outlined,
    'academic_years': Icons.calendar_month_outlined, 'discipline': Icons.rule_outlined, 'awards': Icons.emoji_events_outlined,
    'assets': Icons.inventory_2_outlined, 'transport': Icons.directions_bus_outlined,
  };
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('ټولې برخې', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('د مکتب هره چاره په خپل منظم ځای کې.', style: TextStyle(color: Colors.grey, fontSize: 13))]))),
    SliverPadding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 28), sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.48),
      delegate: SliverChildBuilderDelegate((context, i) {
        final entry = LocalDatabase.modules.entries.elementAt(i);
        return InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ModulePage(table: entry.key, title: entry.value))),
          child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(21)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFE7EFE9), borderRadius: BorderRadius.circular(13)), child: Icon(icons[entry.key] ?? Icons.widgets_outlined, color: green)),
            Row(children: [Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))), const Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: gold)]),
          ])),
        );
      }, childCount: LocalDatabase.modules.length),
    )),
  ]);
}

class ModulePage extends StatefulWidget {
  const ModulePage({super.key, required this.table, required this.title});
  final String table, title;
  @override
  State<ModulePage> createState() => _ModulePageState();
}
class _ModulePageState extends State<ModulePage> {
  late Future<List<Map<String, Object?>>> records;
  @override
  void initState() { super.initState(); records = LocalDatabase.instance.getRecords(widget.table); }
  void refresh() => setState(() => records = LocalDatabase.instance.getRecords(widget.table));

  Future<void> add() async {
    final title = TextEditingController(); final details = TextEditingController();
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('نوی ثبت — ${widget.title}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'نوم / سرلیک', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: details, maxLines: 3, decoration: const InputDecoration(labelText: 'نور معلومات', border: OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('بېرته')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ثبتول'))],
    ));
    if (yes == true && title.text.trim().isNotEmpty) { await LocalDatabase.instance.addRecord(widget.table, title.text, details.text); refresh(); }
    title.dispose(); details.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: refresh, icon: const Icon(Icons.refresh_rounded))]),
    floatingActionButton: FloatingActionButton.extended(onPressed: add, backgroundColor: green, foregroundColor: Colors.white, icon: const Icon(Icons.add_rounded), label: const Text('نوی ثبت')),
    body: FutureBuilder<List<Map<String, Object?>>>(future: records, builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snap.hasError) return const Center(child: Text('د معلوماتو په لوستلو کې ستونزه ده.'));
      final rows = snap.data ?? [];
      if (rows.isEmpty) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inbox_outlined, size: 65, color: gold), SizedBox(height: 14), Text('تر اوسه معلومات نشته', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), SizedBox(height: 6), Text('د نوي ثبت تڼۍ کېکاږئ.', style: TextStyle(color: Colors.grey))]));
      return ListView.separated(padding: const EdgeInsets.fromLTRB(16, 12, 16, 90), itemCount: rows.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (context, i) {
        final row = rows[i];
        return Card(child: ListTile(
          leading: const CircleAvatar(backgroundColor: Color(0xFFE7EFE9), child: Icon(Icons.description_outlined, color: green)),
          title: Text(row['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: (row['details'] as String).isEmpty ? null : Text(row['details'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () async {
            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('حذف تایید کړئ'), content: const Text('دا ثبت حذف شي؟'), actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('نه')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('هو')),
            ]));
            if (confirm == true) { await LocalDatabase.instance.deleteRecord(widget.table, row['id'] as int); refresh(); }
          }),
        ));
      });
    }),
  );
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('راپورونه', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6), const Text('د مکتب د معلوماتو لنډیز او احصایې.', style: TextStyle(color: Colors.grey)),
    const SizedBox(height: 18),
    ...[('زده‌کوونکي', 'students', Icons.school_outlined), ('ښوونکي', 'teachers', Icons.co_present_outlined), ('حاضري', 'attendance', Icons.fact_check_outlined), ('مالي چارې', 'finance', Icons.account_balance_wallet_outlined), ('ازموینې', 'exams', Icons.assignment_outlined)].map((x) => Card(child: FutureBuilder<int>(future: LocalDatabase.instance.count(x.$2), builder: (context, snap) => ListTile(leading: Icon(x.$3, color: green), title: Text(x.$1), trailing: Text('${snap.data ?? 0}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: green)))))),
    const SizedBox(height: 12), const Text('PDF او Excel صادرول به په راتلونکې مرحله کې ورزیات شي.', style: TextStyle(color: Colors.grey, fontSize: 12)),
  ]);
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.dark, required this.onTheme});
  final bool dark; final ValueChanged<bool> onTheme;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('تنظیمات', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6), const Text('د اپلیکیشن او مکتب عمومي تنظیمات.', style: TextStyle(color: Colors.grey)),
    const SizedBox(height: 18),
    Card(child: SwitchListTile(value: dark, onChanged: onTheme, secondary: const Icon(Icons.dark_mode_outlined, color: green), title: const Text('تیاره بڼه', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('د شپې لپاره تیاره رنګونه'))),
    const Card(child: ListTile(leading: Icon(Icons.language, color: green), title: Text('ژبه'), subtitle: Text('اوسنۍ ژبه: پښتو. دري او انګلیسي به په راتلونکې مرحله کې بشپړې شي.'))),
    const Card(child: ListTile(leading: Icon(Icons.school_outlined, color: green), title: Text('د مکتب معلومات'), subtitle: Text('د مکتب نوم، لوګو، پته او اړیکې.'))),
    const Card(child: ListTile(leading: Icon(Icons.backup_outlined, color: green), title: Text('Backup او Restore'), subtitle: Text('د معلوماتو خوندي کاپي او بېرته راګرځول به ورزیات شي.'))),
    const Card(child: ListTile(leading: Icon(Icons.security_outlined, color: green), title: Text('امنیت او صلاحیتونه'), subtitle: Text('د کاروونکو د رولونو او لاسرسي مدیریت به ورزیات شي.'))),
    const SizedBox(height: 20), const Center(child: Text('MAKTAB • نسخه 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2))),
  ]);
}
