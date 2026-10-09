import 'package:flutter/material.dart';

void main() => runApp(const SytadellApp());

// ───────────────────────── Theme ─────────────────────────
const kBg = Color(0xFF000000);
const kCard = Color(0xFF0D0D0D);
const kBorder = Color(0xFF2A2A2A);
const kMuted = Color(0xFF8A8A8A);

// ───────────────────────── Models ─────────────────────────
class Job {
  final String id, title, company, location, type, mode, salary, description;
  final List<String> requirements;
  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.mode,
    required this.salary,
    required this.description,
    this.requirements = const [],
  });
}

class Application {
  final Job job;
  final DateTime date;
  String status;
  Application(this.job, this.date, [this.status = 'Under review']);
}

class Gig {
  final String title, budget, days, details;
  final DateTime posted;
  Gig(this.title, this.budget, this.days, this.details, this.posted);
}

class Community {
  final String name;
  int members;
  bool joined;
  Community(this.name, {this.members = 1, this.joined = true});
}

class Message {
  final String text;
  final bool mine;
  Message(this.text, this.mine);
}

class Chat {
  final String name;
  final List<Message> messages = [];
  Chat(this.name);
}

class AppNotification {
  final String title, body;
  final DateTime time;
  bool read = false;
  AppNotification(this.title, this.body, this.time);
}

// ───────────────────────── State ─────────────────────────
class AppState extends ChangeNotifier {
  String? name, email, password;
  bool get signedIn => name != null;

  final List<Job> postedJobs = [];
  final List<Application> applications = [];
  final Set<String> savedJobIds = {};
  final List<Gig> gigs = [];
  final List<Community> communities = [];
  final List<Chat> chats = [];
  final List<AppNotification> notifications = [];
  final Map<String, String> cv = {};

  String? signUp(String n, String e, String p) {
    if (n.trim().isEmpty) return 'Enter your full name';
    if (!e.contains('@') || !e.contains('.')) return 'Enter a valid email';
    if (p.length < 6) return 'Password must be at least 6 characters';
    name = n.trim();
    email = e.trim();
    password = p;
    notifications.insert(
        0, AppNotification('Welcome to sytadell', 'Your account is ready.', DateTime.now()));
    notifyListeners();
    return null;
  }

  String? signIn(String e, String p) {
    if (email == null) return 'No account found. Please sign up first.';
    if (e.trim() != email || p != password) return 'Incorrect email or password';
    name = name ?? e;
    notifyListeners();
    return null;
  }

  void signOut() {
    name = null;
    notifyListeners();
  }

  void postJob(Job j) {
    postedJobs.insert(0, j);
    _notify('Job posted', '${j.title} is now live.');
  }

  bool hasApplied(Job j) => applications.any((a) => a.job.id == j.id);

  void apply(Job j) {
    if (hasApplied(j)) return;
    applications.insert(0, Application(j, DateTime.now()));
    _notify('Application sent', '${j.title} at ${j.company}');
  }

  void setStatus(Application a, String s) {
    a.status = s;
    _notify('Application status updated', '${a.job.title} at ${a.job.company}: $s');
  }

  void toggleSave(Job j) {
    savedJobIds.contains(j.id) ? savedJobIds.remove(j.id) : savedJobIds.add(j.id);
    notifyListeners();
  }

  void addGig(Gig g) {
    gigs.insert(0, g);
    _notify('Gig posted', g.title);
  }

  void addCommunity(String n) {
    communities.insert(0, Community(n));
    notifyListeners();
  }

  void toggleJoin(Community c) {
    c.joined = !c.joined;
    c.members += c.joined ? 1 : -1;
    notifyListeners();
  }

  Chat startChat(String n) {
    final existing = chats.where((c) => c.name.toLowerCase() == n.toLowerCase());
    if (existing.isNotEmpty) return existing.first;
    final c = Chat(n);
    chats.insert(0, c);
    notifyListeners();
    return c;
  }

  void send(Chat c, String t) {
    c.messages.add(Message(t, true));
    notifyListeners();
  }

  void saveCv(Map<String, String> data) {
    cv.addAll(data);
    notifyListeners();
  }

  void _notify(String t, String b) {
    notifications.insert(0, AppNotification(t, b, DateTime.now()));
    notifyListeners();
  }

  List<Job> get allJobs => postedJobs;
}

class Scope extends InheritedNotifier<AppState> {
  const Scope({super.key, required AppState state, required super.child})
      : super(notifier: state);
  static AppState of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<Scope>()!.notifier!;
}

// ───────────────────────── App ─────────────────────────
class SytadellApp extends StatefulWidget {
  const SytadellApp({super.key});
  @override
  State<SytadellApp> createState() => _SytadellAppState();
}

class _SytadellAppState extends State<SytadellApp> {
  final state = AppState();
  @override
  Widget build(BuildContext context) {
    return Scope(
      state: state,
      child: MaterialApp(
        title: 'sytadell',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kBg,
          colorScheme: const ColorScheme.dark(primary: Colors.white, surface: kBg),
          appBarTheme: const AppBarTheme(
              backgroundColor: kBg, elevation: 0, scrolledUnderElevation: 0),
          bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF111111)),
        ),
        home: const Root(),
      ),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool started = false;
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    if (s.signedIn) return const Shell();
    if (!started) return SplashScreen(onStart: (_) => setState(() => started = true));
    return const AuthScreen();
  }
}

// ───────────────────────── Shared widgets ─────────────────────────
class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) =>
      Icon(Icons.groups_2_rounded, size: size, color: Colors.white);
}

class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  const Btn(this.label, {super.key, this.onTap, this.filled = true});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: filled
            ? FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)))
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: kBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(label)),
      );
}

class Field extends StatelessWidget {
  final TextEditingController c;
  final String label, hint;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboard;
  const Field(this.c, this.label,
      {super.key, this.hint = '', this.obscure = false, this.maxLines = 1, this.keyboard});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            obscureText: obscure,
            maxLines: maxLines,
            keyboardType: keyboard,
            decoration: _dec(hint),
          ),
        ]),
      );
}

InputDecoration _dec(String hint, {Widget? prefix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF5A5A5A)),
      prefixIcon: prefix,
      filled: true,
      fillColor: const Color(0xFF111111),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white54)),
    );

class Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const Empty(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 40, color: kMuted),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
          ]),
        ),
      );
}

class Box extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Box({super.key, required this.child, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: kCard,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), side: const BorderSide(color: kBorder)),
          child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(padding: const EdgeInsets.all(14), child: child)),
        ),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  const Pill(this.text, {super.key, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? Colors.white : kBorder),
            ),
            child: Text(text,
                style: TextStyle(
                    fontSize: 12, color: selected ? Colors.black : Colors.white70)),
          ),
        ),
      );
}

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

String ago(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

// ───────────────────────── Splash & Auth ─────────────────────────
class SplashScreen extends StatelessWidget {
  final ValueChanged<bool> onStart;
  const SplashScreen({super.key, required this.onStart});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(flex: 3),
            const Logo(size: 80),
            const SizedBox(height: 24),
            const Text('Your future\ndeserves a platform.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2)),
            const SizedBox(height: 12),
            const Text('Jobs  ·  Gigs  ·  Learning  ·  Network',
                style: TextStyle(color: kMuted, fontSize: 12)),
            const Spacer(flex: 4),
            Btn('Get Started', onTap: () => onStart(true)),
            const SizedBox(height: 12),
            Btn('I already have an account', filled: false, onTap: () {
              onStart(true);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => Scope(state: s, child: const AuthScreen(signIn: true))));
            }),
          ]),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final bool signIn;
  const AuthScreen({super.key, this.signIn = false});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool signIn = widget.signIn;
  final n = TextEditingController(), e = TextEditingController(), p = TextEditingController();
  String? error;
  bool hide = true;

  void submit() {
    final s = Scope.of(context);
    final err = signIn ? s.signIn(e.text, p.text) : s.signUp(n.text, e.text, p.text);
    if (err != null) {
      setState(() => error = err);
    } else if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          Text(signIn ? 'Welcome back' : 'Create your account',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Join a global community of talent, employers and opportunity.',
              style: TextStyle(color: kMuted, fontSize: 13)),
          const SizedBox(height: 24),
          if (!signIn) Field(n, 'Full name', hint: 'Enter your full name'),
          Field(e, 'Email address', hint: 'you@example.com', keyboard: TextInputType.emailAddress),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Password', style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 6),
              TextField(
                controller: p,
                obscureText: hide,
                decoration: _dec('Create a password').copyWith(
                    suffixIcon: IconButton(
                        icon: Icon(hide ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => hide = !hide))),
              ),
            ]),
          ),
          if (error != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
          Btn(signIn ? 'Sign In' : 'Sign Up', onTap: submit),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                signIn = !signIn;
                error = null;
              }),
              child: Text(signIn ? "Don't have an account? Sign Up" : 'Already have an account? Sign In',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ───────────────────────── Shell ─────────────────────────
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    const pages = [HomeTab(), JobsTab(), NetworkTab(), LearnTab(), ProfileTab()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: i, children: pages)),
      bottomNavigationBar: NavigationBar(
        backgroundColor: kBg,
        indicatorColor: const Color(0xFF222222),
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Network'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

void push(BuildContext c, Widget w) => Navigator.push(
    c, MaterialPageRoute(builder: (_) => Scope(state: Scope.of(c), child: w)));

// ───────────────────────── Home ─────────────────────────
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final first = (s.name ?? '').split(' ').first;
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good day,\n$first', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, height: 1.2)),
            const SizedBox(height: 4),
            const Text('New opportunities. New you.', style: TextStyle(color: kMuted, fontSize: 13)),
          ]),
        ),
        IconButton(
            icon: Badge(
                isLabelVisible: s.notifications.any((n) => !n.read),
                child: const Icon(Icons.notifications_none)),
            onPressed: () => push(context, const NotificationsScreen())),
        IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => push(context, const ChatsScreen())),
      ]),
      const SizedBox(height: 18),
      Box(
        child: Row(children: [
          const Icon(Icons.search, color: kMuted),
          const SizedBox(width: 10),
          const Expanded(child: Text('Search jobs, skills, companies...', style: TextStyle(color: kMuted, fontSize: 13))),
        ]),
        onTap: () => push(context, const JobsTab(standalone: true)),
      ),
      Row(children: [
        _quick(context, Icons.assignment_outlined, 'Applications', const ApplicationsScreen()),
        _quick(context, Icons.description_outlined, 'CV Builder', const CvBuilderScreen()),
        _quick(context, Icons.laptop_mac, 'Freelance', const GigsScreen()),
        _quick(context, Icons.business_center_outlined, 'Employer', const EmployerScreen()),
      ]),
      const SizedBox(height: 18),
      const Text('Recommended for you', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      if (s.allJobs.isEmpty)
        const SizedBox(height: 220, child: Empty(Icons.work_outline, 'No jobs yet. Employers can post roles from the Employer dashboard.'))
      else
        ...s.allJobs.take(5).map((j) => JobTile(j)),
    ]);
  }

  Widget _quick(BuildContext c, IconData i, String l, Widget page) => Expanded(
        child: GestureDetector(
          onTap: () => push(c, page),
          child: Column(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
              child: Icon(i, size: 22),
            ),
            const SizedBox(height: 6),
            Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class JobTile extends StatelessWidget {
  final Job job;
  const JobTile(this.job, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final saved = s.savedJobIds.contains(job.id);
    return Box(
      onTap: () => push(context, JobDetails(job)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(job.company.isEmpty ? '?' : job.company[0].toUpperCase(),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${job.company} · ${job.location} · ${job.mode}',
                style: const TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(height: 6),
            Text('${job.type}  ·  ${job.salary}', style: const TextStyle(fontSize: 12)),
          ]),
        ),
        GestureDetector(
            onTap: () => s.toggleSave(job),
            child: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 20)),
      ]),
    );
  }
}

// ───────────────────────── Jobs ─────────────────────────
class JobsTab extends StatefulWidget {
  final bool standalone;
  const JobsTab({super.key, this.standalone = false});
  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  String q = '';
  bool fullTime = false, remote = false, saved = false;
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final list = s.allJobs.where((j) {
      final t = '${j.title} ${j.company} ${j.description} ${j.requirements.join(' ')}'.toLowerCase();
      return t.contains(q.toLowerCase()) &&
          (!fullTime || j.type == 'Full-time') &&
          (!remote || j.mode == 'Remote') &&
          (!saved || s.savedJobIds.contains(j.id));
    }).toList();
    final body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!widget.standalone)
            const Text('Jobs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: _dec('Search job title, skill or company',
                  prefix: const Icon(Icons.search, size: 18, color: kMuted))),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              Pill('Full-time', selected: fullTime, onTap: () => setState(() => fullTime = !fullTime)),
              Pill('Remote', selected: remote, onTap: () => setState(() => remote = !remote)),
              Pill('Saved', selected: saved, onTap: () => setState(() => saved = !saved)),
            ]),
          ),
          const SizedBox(height: 10),
          Text('${list.length} jobs found', style: const TextStyle(color: kMuted, fontSize: 12)),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? const Empty(Icons.search_off, 'No jobs match yet.')
            : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: list.map(JobTile.new).toList()),
      ),
    ]);
    return widget.standalone ? Scaffold(appBar: AppBar(title: const Text('Search')), body: body) : body;
  }
}

class JobDetails extends StatelessWidget {
  final Job job;
  const JobDetails(this.job, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final applied = s.hasApplied(job);
    final saved = s.savedJobIds.contains(job.id);
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border), onPressed: () => s.toggleSave(job)),
      ]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(job.company, style: const TextStyle(color: kMuted)),
        const SizedBox(height: 4),
        Text(job.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Text('${job.location} · ${job.mode}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text('${job.type} · ${job.salary}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 22),
        const Text('About the role', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(job.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
        if (job.requirements.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Requirements', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...job.requirements.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('›  $r', style: const TextStyle(color: Colors.white70)))),
        ],
      ]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Btn(applied ? 'Applied' : 'Apply now', onTap: applied
              ? null
              : () {
                  s.apply(job);
                  snack(context, 'Application sent');
                }),
        ),
      ),
    );
  }
}

// ───────────────────────── Applications ─────────────────────────
class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String f = 'All';
  static const statuses = ['Under review', 'Interview', 'Offer', 'Rejected'];
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final list = s.applications.where((a) => f == 'All' || a.status == f).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: Column(children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: ['All', ...statuses]
                .map((x) => Pill(x == 'All' ? 'All (${s.applications.length})' : x,
                    selected: f == x, onTap: () => setState(() => f = x)))
                .toList(),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Empty(Icons.assignment_outlined, 'No applications yet.')
              : ListView(padding: const EdgeInsets.all(20), children: [
                  for (final a in list)
                    Box(
                      onTap: () => push(context, JobDetails(a.job)),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(a.job.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${a.job.company} · ${a.job.location}', style: const TextStyle(color: kMuted, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('Applied ${ago(a.date)}', style: const TextStyle(color: kMuted, fontSize: 11)),
                          ]),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) => s.setStatus(a, v),
                          itemBuilder: (_) => statuses.map((x) => PopupMenuItem(value: x, child: Text(x))).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
                            child: Text(a.status, style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      ]),
                    ),
                ]),
        ),
      ]),
    );
  }
}

// ───────────────────────── CV Builder ─────────────────────────
class CvBuilderScreen extends StatefulWidget {
  const CvBuilderScreen({super.key});
  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> {
  int step = 0;
  static const keys = {
    'name': 'Full name',
    'email': 'Email address',
    'phone': 'Phone number',
    'location': 'Location',
    'role': 'Current role',
    'company': 'Company',
    'years': 'Years of experience',
    'skills': 'Skills (comma separated)',
    'about': 'About you',
  };
  late final Map<String, TextEditingController> c = _init();
  Map<String, TextEditingController> _init() {
    final s = Scope.of(context);
    final m = {for (final k in keys.keys) k: TextEditingController(text: s.cv[k] ?? '')};
    m['name']!.text = s.cv['name'] ?? s.name ?? '';
    m['email']!.text = s.cv['email'] ?? s.email ?? '';
    return m;
  }

  Widget stepBody() {
    Widget f(String k, {int lines = 1}) => Field(c[k]!, keys[k]!, maxLines: lines);
    switch (step) {
      case 0:
        return Column(children: [f('name'), f('email'), f('phone'), f('location')]);
      case 1:
        return Column(children: [f('role'), f('company'), f('years')]);
      case 2:
        return Column(children: [f('skills'), f('about', lines: 4)]);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: c.entries
              .where((e) => e.value.text.trim().isNotEmpty)
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(keys[e.key]!, style: const TextStyle(color: kMuted, fontSize: 12)),
                      Text(e.value.text),
                    ]),
                  ))
              .toList(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Personal', 'Experience', 'Skills', 'Review'];
    return Scaffold(
      appBar: AppBar(title: const Text('Build your CV')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          for (var i = 0; i < 4; i++)
            Expanded(
              child: Column(children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: i <= step ? Colors.white : kBorder,
                  child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: i <= step ? Colors.black : Colors.white)),
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: const TextStyle(fontSize: 11, color: kMuted)),
              ]),
            ),
        ]),
        const SizedBox(height: 24),
        Text(labels[step] == 'Review' ? 'Review' : '${labels[step]} information',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        stepBody(),
        Row(children: [
          if (step > 0) Expanded(child: Btn('Back', filled: false, onTap: () => setState(() => step--))),
          if (step > 0) const SizedBox(width: 10),
          Expanded(
            child: Btn(step == 3 ? 'Save CV' : 'Next', onTap: () {
              if (step < 3) {
                setState(() => step++);
              } else {
                Scope.of(context).saveCv({for (final e in c.entries) e.key: e.value.text.trim()});
                snack(context, 'CV saved');
                Navigator.pop(context);
              }
            }),
          ),
        ]),
      ]),
    );
  }
}

// ───────────────────────── Network ─────────────────────────
class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        child: Row(children: [
          const Expanded(child: Text('Network', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600))),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => askText(context, 'New community', 'Community name', s.addCommunity)),
        ]),
      ),
      Expanded(
        child: s.communities.isEmpty
            ? const Empty(Icons.groups_outlined, 'No communities yet. Tap + to start one.')
            : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
                for (final cm in s.communities)
                  Box(
                    child: Row(children: [
                      const Icon(Icons.groups_2_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(cm.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${cm.members} members', style: const TextStyle(color: kMuted, fontSize: 12)),
                      ])),
                      Pill(cm.joined ? 'Joined' : 'Join', selected: !cm.joined, onTap: () => s.toggleJoin(cm)),
                    ]),
                  ),
              ]),
      ),
    ]);
  }
}

void askText(BuildContext context, String title, String hint, void Function(String) onOk) {
  final t = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF111111),
      title: Text(title),
      content: TextField(controller: t, autofocus: true, decoration: _dec(hint)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              if (t.text.trim().isNotEmpty) onOk(t.text.trim());
              Navigator.pop(context);
            },
            child: const Text('OK')),
      ],
    ),
  );
}

// ───────────────────────── Learn ─────────────────────────
class LearnTab extends StatelessWidget {
  const LearnTab({super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Learn & Grow', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Build your skills and unlock new opportunities.', style: TextStyle(color: kMuted, fontSize: 13)),
          const SizedBox(height: 14),
          TextField(decoration: _dec('Search courses, skills or topics', prefix: const Icon(Icons.search, size: 18, color: kMuted))),
          const Expanded(child: Empty(Icons.menu_book_outlined, 'Courses will appear here once they are published.')),
        ]),
      );
}

// ───────────────────────── Profile ─────────────────────────
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final cv = s.cv;
    final skills = (cv['skills'] ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    final interviews = s.applications.where((a) => a.status == 'Interview').length;
    final offers = s.applications.where((a) => a.status == 'Offer').length;
    Widget stat(String n, String l) => Expanded(
        child: Column(children: [
      Text(n, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      Text(l, style: const TextStyle(color: kMuted, fontSize: 12)),
    ]));
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => push(context, const SettingsScreen())),
      ]),
      Center(
        child: Column(children: [
          CircleAvatar(
              radius: 40,
              backgroundColor: kBorder,
              child: Text((s.name ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 30))),
          const SizedBox(height: 12),
          Text(s.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          if ((cv['role'] ?? '').isNotEmpty) Text(cv['role']!, style: const TextStyle(color: Colors.white70)),
          if ((cv['location'] ?? '').isNotEmpty) Text(cv['location']!, style: const TextStyle(color: kMuted, fontSize: 12)),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        stat('${s.applications.length}', 'Applications'),
        stat('$interviews', 'Interviews'),
        stat('$offers', 'Offers'),
      ]),
      const SizedBox(height: 20),
      Btn('Edit profile / CV', onTap: () => push(context, const CvBuilderScreen())),
      const SizedBox(height: 20),
      const Text('About me', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text((cv['about'] ?? '').isEmpty ? 'Add a short bio from your CV.' : cv['about']!,
          style: const TextStyle(color: Colors.white70, height: 1.4)),
      if (skills.isNotEmpty) ...[
        const SizedBox(height: 14),
        Wrap(runSpacing: 6, children: skills.map((e) => Pill(e)).toList()),
      ],
      if ((cv['company'] ?? '').isNotEmpty) ...[
        const SizedBox(height: 18),
        const Text('Experience', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('${cv['role'] ?? ''} · ${cv['company']}${(cv['years'] ?? '').isEmpty ? '' : ' · ${cv['years']} yrs'}',
            style: const TextStyle(color: Colors.white70)),
      ],
      const SizedBox(height: 18),
      _link(context, Icons.assignment_outlined, 'My Applications', const ApplicationsScreen()),
      _link(context, Icons.laptop_mac, 'Freelance gigs', const GigsScreen()),
      _link(context, Icons.business_center_outlined, 'Employer dashboard', const EmployerScreen()),
    ]);
  }

  Widget _link(BuildContext c, IconData i, String l, Widget p) => Box(
        onTap: () => push(c, p),
        child: Row(children: [Icon(i, size: 20), const SizedBox(width: 12), Expanded(child: Text(l)), const Icon(Icons.chevron_right, color: kMuted)]),
      );
}

// ───────────────────────── Employer ─────────────────────────
class EmployerScreen extends StatelessWidget {
  const EmployerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    Widget stat(String n, String l) => Expanded(
        child: Box(
            child: Column(children: [
      Text(n, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      Text(l, style: const TextStyle(color: kMuted, fontSize: 11), textAlign: TextAlign.center),
    ])));
    return Scaffold(
      appBar: AppBar(title: const Text('Talent Dashboard')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          stat('${s.postedJobs.length}', 'Jobs posted'),
          const SizedBox(width: 8),
          stat('${s.applications.where((a) => s.postedJobs.contains(a.job)).length}', 'Applicants'),
        ]),
        const SizedBox(height: 8),
        Btn('Post a job', onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => Scope(state: s, child: const PostJobSheet()),
            )),
        const SizedBox(height: 20),
        const Text('Your jobs', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (s.postedJobs.isEmpty) const SizedBox(height: 200, child: Empty(Icons.work_outline, 'You have not posted any jobs.')),
        ...s.postedJobs.map(JobTile.new),
      ]),
    );
  }
}

class PostJobSheet extends StatefulWidget {
  const PostJobSheet({super.key});
  @override
  State<PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends State<PostJobSheet> {
  final t = TextEditingController(), co = TextEditingController(), loc = TextEditingController();
  final sal = TextEditingController(), d = TextEditingController(), req = TextEditingController();
  String type = 'Full-time', mode = 'On-site';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Post a job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Field(t, 'Job title'),
          Field(co, 'Company'),
          Field(loc, 'Location'),
          Field(sal, 'Salary', hint: r'$1,000 - $2,000 / month'),
          Field(d, 'Description', maxLines: 3),
          Field(req, 'Requirements (one per line)', maxLines: 3),
          Wrap(children: [
            for (final x in ['Full-time', 'Part-time', 'Contract']) Pill(x, selected: type == x, onTap: () => setState(() => type = x)),
          ]),
          const SizedBox(height: 8),
          Wrap(children: [
            for (final x in ['On-site', 'Remote', 'Hybrid']) Pill(x, selected: mode == x, onTap: () => setState(() => mode = x)),
          ]),
          const SizedBox(height: 14),
          Btn('Publish', onTap: () {
            if (t.text.trim().isEmpty || co.text.trim().isEmpty) {
              snack(context, 'Title and company are required');
              return;
            }
            Scope.of(context).postJob(Job(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: t.text.trim(),
              company: co.text.trim(),
              location: loc.text.trim().isEmpty ? 'Anywhere' : loc.text.trim(),
              type: type,
              mode: mode,
              salary: sal.text.trim().isEmpty ? 'Not disclosed' : sal.text.trim(),
              description: d.text.trim(),
              requirements: req.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            ));
            Navigator.pop(context);
          }),
        ]),
      ),
    );
  }
}

// ───────────────────────── Freelance ─────────────────────────
class GigsScreen extends StatelessWidget {
  const GigsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Freelance Gigs'), actions: [
        IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final t = TextEditingController(), b = TextEditingController(), dy = TextEditingController(), dt = TextEditingController();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Field(t, 'Gig title'),
                      Field(b, 'Budget', hint: r'$500 - $1,000'),
                      Field(dy, 'Duration', hint: '7 days'),
                      Field(dt, 'Details', maxLines: 3),
                      Btn('Post gig', onTap: () {
                        if (t.text.trim().isEmpty) return;
                        s.addGig(Gig(t.text.trim(), b.text.trim(), dy.text.trim(), dt.text.trim(), DateTime.now()));
                        Navigator.pop(context);
                      }),
                    ]),
                  ),
                ),
              );
            }),
      ]),
      body: s.gigs.isEmpty
          ? const Empty(Icons.laptop_mac, 'No gigs yet. Tap + to post one.')
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final g in s.gigs)
                Box(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(g.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${g.budget}  ·  ${g.days}', style: const TextStyle(color: kMuted, fontSize: 12)),
                    if (g.details.isNotEmpty) ...[const SizedBox(height: 6), Text(g.details, style: const TextStyle(color: Colors.white70))],
                    const SizedBox(height: 6),
                    Text('Posted ${ago(g.posted)}', style: const TextStyle(color: kMuted, fontSize: 11)),
                  ]),
                ),
            ]),
    );
  }
}

// ───────────────────────── Messages ─────────────────────────
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), actions: [
        IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => askText(context, 'New message', 'Person name', (n) => push(context, ChatScreen(s.startChat(n))))),
      ]),
      body: s.chats.isEmpty
          ? const Empty(Icons.chat_bubble_outline, 'No conversations yet.')
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final c in s.chats)
                Box(
                  onTap: () => push(context, ChatScreen(c)),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: kBorder, child: Text(c.name[0].toUpperCase())),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(c.messages.isEmpty ? 'Say hello' : c.messages.last.text,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 12)),
                    ])),
                  ]),
                ),
            ]),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Chat chat;
  const ChatScreen(this.chat, {super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final t = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.name)),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            for (final m in widget.chat.messages)
              Align(
                alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                      color: m.mine ? Colors.white : const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(14)),
                  child: Text(m.text, style: TextStyle(color: m.mine ? Colors.black : Colors.white)),
                ),
              ),
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: t, decoration: _dec('Message'))),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (t.text.trim().isEmpty) return;
                    s.send(widget.chat, t.text.trim());
                    t.clear();
                  }),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────── Notifications ─────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    for (final n in s.notifications) {
      n.read = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: s.notifications.isEmpty
          ? const Empty(Icons.notifications_none, 'You are all caught up.')
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final n in s.notifications)
                Box(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(n.body, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(ago(n.time), style: const TextStyle(color: kMuted, fontSize: 11)),
                  ]),
                ),
            ]),
    );
  }
}

// ───────────────────────── Settings ─────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Box(
          child: Row(children: [
            CircleAvatar(radius: 24, backgroundColor: kBorder, child: Text((s.name ?? '?')[0].toUpperCase())),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(s.email ?? '', style: const TextStyle(color: kMuted, fontSize: 12)),
            ]),
          ]),
        ),
        Box(onTap: () => push(context, const NotificationsScreen()), child: const Row(children: [Icon(Icons.notifications_none, size: 20), SizedBox(width: 12), Text('Notifications')])),
        Box(onTap: () => push(context, const ChatsScreen()), child: const Row(children: [Icon(Icons.chat_bubble_outline, size: 20), SizedBox(width: 12), Text('Messages')])),
        const SizedBox(height: 20),
        Btn('Sign out', filled: false, onTap: () {
          s.signOut();
          Navigator.popUntil(context, (r) => r.isFirst);
        }),
      ]),
    );
  }
}
