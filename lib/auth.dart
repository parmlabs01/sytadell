import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';

class SplashScreen extends StatelessWidget {
  final ValueChanged<bool> onStart; // true = go to sign in
  const SplashScreen({super.key, required this.onStart});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(flex: 3),
              const Logo(size: 84),
              const SizedBox(height: 24),
              const Text('Your future\ndeserves a platform.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2)),
              const SizedBox(height: 12),
              Text('Jobs  ·  Gigs  ·  Learning  ·  Network', style: TextStyle(color: context.mutedc, fontSize: 12)),
              const Spacer(flex: 4),
              Btn('Get Started', onTap: () => onStart(false)),
              const SizedBox(height: 12),
              Btn('I already have an account', filled: false, onTap: () => onStart(true)),
            ]),
          ),
        ),
      );
}

class AuthScreen extends StatefulWidget {
  final bool signIn;
  final VoidCallback onBack;
  const AuthScreen({super.key, required this.signIn, required this.onBack});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool signIn = widget.signIn;
  final n = TextEditingController(), e = TextEditingController(), p = TextEditingController(), ph = TextEditingController();
  String role = 'Job seeker';
  String? error;
  bool hide = true, remember = true;

  void submit() {
    final s = S(context);
    final err = signIn ? s.signIn(e.text, p.text, remember) : s.signUp(n.text, e.text, p.text, ph.text, role);
    if (err != null) setState(() => error = err);
  }

  void social(String what) => snack(context, '$what sign-in needs a backend (Firebase/Supabase) to be connected.');

  void forgot() {
    final em = TextEditingController(text: e.text), pw = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Reset password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Field(em, 'Account email'),
          Field(pw, 'New password', obscure: true, hint: '8+ characters with a number'),
          Btn('Reset password', onTap: () {
            final err = S(context).resetPassword(em.text, pw.text);
            Navigator.pop(ctx);
            snack(context, err ?? 'Password updated. Sign in with your new password.');
          }),
        ]),
      ),
    );
  }

  Widget social3() => Column(children: [
        Row(children: [
          Expanded(child: Divider(color: context.linec)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: context.mutedc, fontSize: 12))),
          Expanded(child: Divider(color: context.linec)),
        ]),
        const SizedBox(height: 14),
        Btn('Continue with Google', filled: false, icon: Icons.g_mobiledata, onTap: () => social('Google')),
        const SizedBox(height: 10),
        Btn('Continue with Apple', filled: false, icon: Icons.apple, onTap: () => social('Apple')),
        const SizedBox(height: 10),
        Btn('Continue with Email', filled: false, icon: Icons.mail_outline, onTap: () => setState(() => error = null)),
      ]);

  @override
  Widget build(BuildContext context) {
    final pwField = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: p,
        obscureText: hide,
        decoration: dec(context, signIn ? 'Password' : 'Create a password',
            prefix: Icon(Icons.lock_outline, size: 20, color: context.mutedc),
            suffix: IconButton(icon: Icon(hide ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => hide = !hide))),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          Row(children: [
            const Logo(size: 40),
            const Spacer(),
            TextButton.icon(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back, size: 18), label: const Text('Back to home')),
          ]),
          Text('YOUR CAREER   ·   OUR MISSION', style: TextStyle(letterSpacing: 2.5, fontSize: 10.5, color: context.mutedc)),
          const SizedBox(height: 24),
          Text(signIn ? 'Welcome\nback' : 'Create your\naccount', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, height: 1.05)),
          const SizedBox(height: 10),
          Text(signIn ? 'Sign in to continue your journey.\nYour next opportunity is waiting.' : 'Join a global community of talent,\nemployers and opportunity.',
              style: TextStyle(color: context.mutedc, fontSize: 15)),
          const SizedBox(height: 24),
          if (!signIn) Field(n, '', hint: 'Full name', icon: Icons.person_outline),
          Field(e, '', hint: signIn ? 'Email address or phone number' : 'you@example.com', icon: signIn ? Icons.person_outline : Icons.mail_outline, keyboard: TextInputType.emailAddress),
          pwField,
          if (!signIn) ...[
            Padding(
                padding: const EdgeInsets.only(bottom: 14, left: 2),
                child: Text('Password must be at least 8 characters and include a number.', style: TextStyle(fontSize: 12, color: context.mutedc))),
            Field(ph, '', hint: 'Phone number (optional)  +234 801 234 5678', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
            const Text('I am a', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              for (final r in ['Job seeker', 'Employer'])
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: r == 'Job seeker' ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => role = r),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: role == r ? context.fg : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: role == r ? context.fg : context.linec)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(r == 'Employer' ? Icons.apartment : Icons.person_outline, size: 18, color: role == r ? context.bgc : context.fg),
                          const SizedBox(width: 6),
                          Text(r, style: TextStyle(color: role == r ? context.bgc : context.fg, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 18),
          ],
          if (signIn)
            Row(children: [
              Checkbox(value: remember, onChanged: (v) => setState(() => remember = v ?? true)),
              const Text('Remember me'),
              const Spacer(),
              TextButton(onPressed: forgot, child: const Text('Forgot password?')),
            ]),
          if (error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
          Btn(signIn ? 'Sign in' : 'Create account', icon: Icons.arrow_forward, onTap: submit),
          const SizedBox(height: 18),
          social3(),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                signIn = !signIn;
                error = null;
              }),
              child: Text(signIn ? "Don't have an account?  Sign up →" : 'Already have an account?  Sign in →'),
            ),
          ),
        ]),
      ),
    );
  }
}

class CareerPathScreen extends StatelessWidget {
  const CareerPathScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    Widget card(IconData i, String t, String d, String path) => Box(
          onTap: () => s.choosePath(path),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: context.fg.withOpacity(.08), borderRadius: BorderRadius.circular(16)),
                child: Icon(i, size: 26)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(d, style: TextStyle(color: context.mutedc, fontSize: 13)),
            ])),
            const Icon(Icons.arrow_circle_right_outlined),
          ]),
        );
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const Logo(size: 40),
          Text('YOUR CAREER   ·   OUR MISSION', style: TextStyle(letterSpacing: 2.5, fontSize: 10.5, color: context.mutedc)),
          const SizedBox(height: 24),
          const Text('Choose your\ncareer path', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, height: 1.05)),
          const SizedBox(height: 10),
          Text("Tell us what you're here for, and we'll personalize your experience.", style: TextStyle(color: context.mutedc)),
          const SizedBox(height: 22),
          card(Icons.work_outline, 'Find a Job', 'Explore verified job opportunities from companies and growing startups.', 'job'),
          card(Icons.laptop_mac, 'Offer Freelance Services', 'Showcase your skills, get hired for projects, and work with clients worldwide.', 'freelance'),
          card(Icons.groups_2_outlined, 'Hire Talent', 'Find the right people for your team. Post jobs, review candidates, and build great teams.', 'hire'),
          card(Icons.school_outlined, 'Build Your Skills', 'Access courses, get certified, and gain the skills you need to grow your career.', 'learn'),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: () => s.choosePath('home'), child: const Text('Not sure?  Explore all features →'))),
        ]),
      ),
    );
  }
}
