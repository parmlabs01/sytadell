import 'package:flutter/material.dart';
import 'auth.dart';
import 'freelance.dart';
import 'jobs.dart';
import 'learn.dart';
import 'talent.dart';
import 'misc.dart';
import 'profile.dart';
import 'state.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(SytadellApp(state: state));
}

ThemeData _theme(Brightness b) {
  final dark = b == Brightness.dark;
  final bg = dark ? Colors.black : Colors.white;
  final fg = dark ? Colors.white : Colors.black;
  return ThemeData(
    brightness: b,
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme(
      brightness: b,
      primary: fg,
      onPrimary: bg,
      secondary: fg,
      onSecondary: bg,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: bg,
      onSurface: fg,
    ),
    appBarTheme: AppBarTheme(backgroundColor: bg, foregroundColor: fg, elevation: 0, scrolledUnderElevation: 0, centerTitle: false),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: dark ? const Color(0xFF111111) : Colors.white),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: dark ? const Color(0xFF222222) : const Color(0xFFE8E8E8),
      labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12)),
    ),
    dividerColor: dark ? const Color(0xFF2A2A2A) : const Color(0xFFDADADA),
  );
}

class SytadellApp extends StatelessWidget {
  final AppState state;
  const SytadellApp({super.key, required this.state});
  @override
  Widget build(BuildContext context) => Scope(
        state: state,
        child: Builder(
          builder: (context) {
            final s = Scope.of(context);
            return MaterialApp(
              title: 'sytadell',
              debugShowCheckedModeBanner: false,
              themeMode: s.themeMode,
              theme: _theme(Brightness.light),
              darkTheme: _theme(Brightness.dark),
              home: const Root(),
            );
          },
        ),
      );
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool started = false, signIn = false;
  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    if (s.signedIn) return s.pathChosen ? const Shell() : const CareerPathScreen();
    if (!started) return SplashScreen(onStart: (si) => setState(() {started = true; signIn = si;}));
    return AuthScreen(key: ValueKey(signIn), signIn: signIn, onBack: () => setState(() => started = false));
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = Scope.of(context);
      final p = s.pending;
      s.pending = null;
      if (p == 'freelance') push(context, const FreelanceScreen());
      if (p == 'hire') push(context, const EmployerScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    const pages = [HomeTab(), JobsTab(), NetworkTab(), LearnTab(), ProfileTab()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: s.tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: s.tab,
        onDestinationSelected: s.setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Network'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
