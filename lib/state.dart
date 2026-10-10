import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ───────────── Models ─────────────
class Exp {
  final String role, company, period, details;
  Exp(this.role, this.company, this.period, this.details);
}

class Edu {
  final String degree, school, period;
  Edu(this.degree, this.school, this.period);
}

class Port {
  final String title, type;
  Port(this.title, this.type);
}

class Ach {
  final String title, sub;
  Ach(this.title, this.sub);
}

class Job {
  final String id, title, company, location, type, mode, experience, salary, about;
  final List<String> skills, responsibilities, requirements;
  final DateTime posted;
  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.mode,
    required this.experience,
    required this.salary,
    required this.about,
    this.skills = const [],
    this.responsibilities = const [],
    this.requirements = const [],
    required this.posted,
  });
}

const kStatuses = ['Applied', 'Under review', 'Shortlisted', 'Interview', 'Offer', 'Rejected', 'Archived'];

class Application {
  final Job job;
  final DateTime date;
  final String cv, cover;
  final Map<String, String> answers;
  String status;
  Application(this.job, this.date, this.cv, this.cover, this.answers, [this.status = 'Applied']);
}

class Service {
  final String id, title, category, sub, desc, seller;
  final List<String> skills;
  final int price, revisions;
  final String delivery;
  final bool featured, discount, custom, mine;
  final DateTime posted;
  Service({
    required this.id,
    required this.title,
    required this.category,
    required this.sub,
    required this.desc,
    required this.seller,
    required this.skills,
    required this.price,
    required this.delivery,
    required this.revisions,
    required this.featured,
    required this.discount,
    required this.custom,
    required this.mine,
    required this.posted,
    this.packages = const [],
    this.faqs = const [],
  });
  final List<Package> packages;
  final List<String> faqs;
}

class Proposal {
  final Service service;
  final String message;
  final DateTime date;
  Proposal(this.service, this.message, this.date);
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
  final String title, body, cat;
  final DateTime time;
  bool read = false;
  AppNotification(this.title, this.body, this.cat, this.time);
}

class Package {
  final String name, delivery;
  final int price;
  final List<String> features;
  Package(this.name, this.price, this.delivery, this.features);
}

class Course {
  final String id, title, category, level, description, author;
  final List<String> lessons;
  final Set<int> done = {};
  bool enrolled = false;
  Course(this.id, this.title, this.category, this.level, this.description, this.author, this.lessons);
  double get progress => lessons.isEmpty ? 0 : done.length / lessons.length;
}

const kTemplates = <String, int>{
  'Modern Pro': 0xFF2563EB,
  'Minimal': 0xFF111111,
  'Creative': 0xFF9333EA,
  'Executive': 0xFF1F2937,
  'Tech': 0xFF059669,
};
const kTemplateGroups = <String, List<String>>{
  'Modern': ['Modern Pro', 'Tech'],
  'Classic': ['Minimal', 'Executive'],
  'Creative': ['Creative'],
};

String _hash(String s) {
  var h = 2166136261;
  for (final c in s.codeUnits) {
    h = ((h ^ c) * 16777619) & 0xFFFFFFFF;
  }
  return h.toRadixString(16);
}

// ───────────── State ─────────────
class AppState extends ChangeNotifier {
  SharedPreferences? _p;

  // appearance & settings
  ThemeMode themeMode = ThemeMode.system;
  bool notifJobs = true, notifMessages = true, notifApplications = true;

  // account
  String? name, email, phone, role;
  String _pass = '';
  bool signedIn = false, pathChosen = false;
  int tab = 0;
  String? pending;

  // profile
  String headline = '', location = '', about = '', website = '', years = '';
  bool available = true;
  List<String> skills = [];
  final List<Exp> exps = [];
  final List<Edu> edus = [];
  final List<Port> ports = [];
  final List<Ach> achs = [];
  final List<String> certs = [];
  String cvTemplate = 'Modern Pro';

  // data
  final List<Job> jobs = [];
  final List<Application> applications = [];
  final Set<String> savedJobs = {};
  final Map<String, Map<String, String>> drafts = {};
  int applyGoal = 15;
  final List<Service> services = [];
  final Set<String> savedServices = {};
  final List<Proposal> proposals = [];
  final List<Course> courses = [];
  final List<Community> communities = [];
  final List<Chat> chats = [];
  final List<AppNotification> notifications = [];

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final p = _p!;
    themeMode = ThemeMode.values[(p.getInt('theme') ?? 0).clamp(0, 2)];
    name = p.getString('name');
    email = p.getString('email');
    phone = p.getString('phone');
    role = p.getString('role');
    _pass = p.getString('pass') ?? '';
    signedIn = name != null && (p.getBool('remember') ?? false);
    pathChosen = p.getBool('path') ?? false;
    headline = p.getString('headline') ?? '';
    location = p.getString('location') ?? '';
    about = p.getString('about') ?? '';
    website = p.getString('website') ?? '';
    years = p.getString('years') ?? '';
    available = p.getBool('available') ?? true;
    skills = p.getStringList('skills') ?? [];
    cvTemplate = p.getString('tpl') ?? 'Modern Pro';
    notifJobs = p.getBool('nJobs') ?? true;
    notifMessages = p.getBool('nMsg') ?? true;
    notifApplications = p.getBool('nApp') ?? true;
  }

  void _save() {
    final p = _p;
    if (p == null) return;
    p.setInt('theme', themeMode.index);
    if (name != null) {
      p.setString('name', name!);
      p.setString('email', email ?? '');
      p.setString('phone', phone ?? '');
      p.setString('role', role ?? 'Job seeker');
      p.setString('pass', _pass);
    }
    p.setBool('path', pathChosen);
    p.setString('headline', headline);
    p.setString('location', location);
    p.setString('about', about);
    p.setString('website', website);
    p.setString('years', years);
    p.setBool('available', available);
    p.setStringList('skills', skills);
    p.setString('tpl', cvTemplate);
    p.setBool('nJobs', notifJobs);
    p.setBool('nMsg', notifMessages);
    p.setBool('nApp', notifApplications);
  }

  void change() {
    _save();
    notifyListeners();
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    change();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  // ── auth
  String? signUp(String n, String e, String pw, String ph, String r) {
    if (n.trim().isEmpty) return 'Enter your full name';
    if (!e.contains('@') || !e.contains('.')) return 'Enter a valid email';
    if (pw.length < 8 || !pw.contains(RegExp(r'[0-9]'))) {
      return 'Password must be at least 8 characters and include a number';
    }
    name = n.trim();
    email = e.trim().toLowerCase();
    phone = ph.trim();
    role = r;
    _pass = _hash(pw);
    signedIn = true;
    _p?.setBool('remember', true);
    _notify('Welcome to sytadell', 'Your account is ready. Complete your profile to get better matches.', 'System');
    change();
    return null;
  }

  String? signIn(String id, String pw, bool remember) {
    if (name == null) return 'No account found on this device. Please sign up first.';
    final i = id.trim().toLowerCase();
    final okId = i == email || (phone != null && phone!.isNotEmpty && i.replaceAll(' ', '') == phone!.replaceAll(' ', ''));
    if (!okId || _hash(pw) != _pass) return 'Incorrect email/phone or password';
    signedIn = true;
    _p?.setBool('remember', remember);
    notifyListeners();
    return null;
  }

  String? resetPassword(String e, String pw) {
    if (e.trim().toLowerCase() != email) return 'No account with that email';
    if (pw.length < 8 || !pw.contains(RegExp(r'[0-9]'))) return 'Use 8+ characters with a number';
    _pass = _hash(pw);
    _save();
    return null;
  }

  String? changePassword(String old, String pw) {
    if (_hash(old) != _pass) return 'Current password is incorrect';
    return resetPassword(email ?? '', pw);
  }

  void signOut() {
    signedIn = false;
    tab = 0;
    _p?.setBool('remember', false);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _p?.clear();
    name = email = phone = role = null;
    _pass = '';
    signedIn = pathChosen = false;
    headline = location = about = website = years = '';
    skills = [];
    courses.clear();
    for (final l in [exps, edus, ports, achs, certs, jobs, applications, services, proposals, communities, chats, notifications]) {
      l.clear();
    }
    savedJobs.clear();
    savedServices.clear();
    tab = 0;
    themeMode = ThemeMode.system;
    notifyListeners();
  }

  void choosePath(String path) {
    pathChosen = true;
    switch (path) {
      case 'job':
        tab = 1;
        break;
      case 'learn':
        tab = 3;
        break;
      default:
        tab = 0;
        pending = path;
    }
    change();
  }

  // ── profile
  double get completion {
    final checks = [
      headline.isNotEmpty,
      location.isNotEmpty,
      about.isNotEmpty,
      (phone ?? '').isNotEmpty,
      website.isNotEmpty,
      skills.isNotEmpty,
      exps.isNotEmpty,
      edus.isNotEmpty,
      ports.isNotEmpty,
      achs.isNotEmpty || certs.isNotEmpty,
    ];
    return checks.where((e) => e).length / checks.length;
  }

  List<String> get missingProfile {
    final m = <String, bool>{
      'a headline': headline.isEmpty,
      'your location': location.isEmpty,
      'an About me summary': about.isEmpty,
      'a phone number': (phone ?? '').isEmpty,
      'a website or portfolio link': website.isEmpty,
      'your skills': skills.isEmpty,
      'work experience': exps.isEmpty,
      'education': edus.isEmpty,
      'portfolio projects': ports.isEmpty,
      'achievements or certifications': achs.isEmpty && certs.isEmpty,
    };
    return m.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  void add<T>(List<T> l, T v) {
    l.add(v);
    change();
  }

  void remove<T>(List<T> l, T v) {
    l.remove(v);
    change();
  }

  // ── jobs
  int? matchOf(Job j) {
    if (skills.isEmpty || j.skills.isEmpty) return null;
    final mine = skills.map((e) => e.toLowerCase()).toSet();
    final hit = j.skills.where((s) => mine.contains(s.toLowerCase())).length;
    return (hit * 100 / j.skills.length).round();
  }

  void postJob(Job j) {
    jobs.insert(0, j);
    if (notifJobs) _notify('New job posted', '${j.title} at ${j.company} is now live.', 'Jobs');
    change();
  }

  bool hasApplied(Job j) => applications.any((a) => a.job.id == j.id);

  void apply(Job j, String cv, String cover, Map<String, String> answers) {
    if (hasApplied(j)) return;
    applications.insert(0, Application(j, DateTime.now(), cv, cover, answers));
    drafts.remove(j.id);
    if (notifApplications) _notify('Application sent', '${j.title} at ${j.company}', 'Applications');
    change();
  }

  void setStatus(Application a, String s) {
    a.status = s;
    if (notifApplications) _notify('Application update', '"${a.job.title}" is now: $s', 'Applications');
    change();
  }

  void toggleSaveJob(Job j) {
    savedJobs.contains(j.id) ? savedJobs.remove(j.id) : savedJobs.add(j.id);
    notifyListeners();
  }

  // ── services
  void addService(Service s) {
    services.insert(0, s);
    _notify('Service posted', s.title, 'System');
    change();
  }

  void toggleSaveService(Service s) {
    savedServices.contains(s.id) ? savedServices.remove(s.id) : savedServices.add(s.id);
    notifyListeners();
  }

  void sendProposal(Service s, String m) {
    proposals.insert(0, Proposal(s, m, DateTime.now()));
    change();
  }

  // ── learning
  void addCourse(Course c) {
    courses.insert(0, c);
    change();
  }

  void toggleEnroll(Course c) {
    c.enrolled = !c.enrolled;
    notifyListeners();
  }

  void toggleLesson(Course c, int i) {
    c.enrolled = true;
    c.done.contains(i) ? c.done.remove(i) : c.done.add(i);
    if (c.progress >= 1) _notify('Course completed', 'You finished "${c.title}".', 'System');
    notifyListeners();
  }

  void removeJob(Job j) {
    jobs.remove(j);
    change();
  }

  // ── social
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
    final ex = chats.where((c) => c.name.toLowerCase() == n.toLowerCase());
    if (ex.isNotEmpty) return ex.first;
    final c = Chat(n);
    chats.insert(0, c);
    notifyListeners();
    return c;
  }

  void send(Chat c, String t) {
    c.messages.add(Message(t, true));
    notifyListeners();
  }

  void _notify(String t, String b, String cat) {
    notifications.insert(0, AppNotification(t, b, cat, DateTime.now()));
  }

  void markAllRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }
}

class Scope extends InheritedNotifier<AppState> {
  const Scope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<Scope>()!.notifier!;
}
