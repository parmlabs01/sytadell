import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';

// ───────────── Network ─────────────
class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
        child: Row(children: [
          const Expanded(child: Heading('Network', 'Join communities and meet people.')),
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => push(context, const ChatsScreen())),
          IconButton(icon: const Icon(Icons.add), onPressed: () => askForm(context, 'New community', ['Community name'], (v) => ifFilled(v[0], () => s.addCommunity(v[0])))),
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
                        Text('${cm.members} members', style: TextStyle(color: context.mutedc, fontSize: 12)),
                      ])),
                      Pill(cm.joined ? 'Joined' : 'Join', selected: !cm.joined, onTap: () => s.toggleJoin(cm)),
                    ]),
                  ),
              ]),
      ),
    ]);
  }
}

// ───────────── Notifications ─────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String f = 'All';
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    int count(String c) => c == 'All' ? s.notifications.length : s.notifications.where((n) => n.cat == c).length;
    final list = s.notifications.where((n) => f == 'All' || n.cat == f).toList();
    IconData icon(String c) => c == 'Jobs' ? Icons.work_outline : c == 'Applications' ? Icons.description_outlined : c == 'Messages' ? Icons.chat_bubble_outline : Icons.settings_outlined;
    return Scaffold(
      appBar: AppBar(
        title: const Heading('Job Alerts & Notifications', 'Stay updated on opportunities and progress.'),
        toolbarHeight: 70,
        actions: [IconButton(icon: const Icon(Icons.done_all), tooltip: 'Mark all read', onPressed: s.markAllRead)],
      ),
      body: Column(children: [
        SizedBox(
          height: 46,
          child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: ['All', 'Jobs', 'Applications', 'Messages', 'System'].map((c) => Pill('$c  ${count(c)}', selected: f == c, onTap: () => setState(() => f = c))).toList()),
        ),
        Expanded(
          child: list.isEmpty
              ? const Empty(Icons.notifications_none, 'You are all caught up.')
              : ListView(padding: const EdgeInsets.all(20), children: [
                  for (final n in list)
                    Box(
                      onTap: () {
                        n.read = true;
                        s.setTab(s.tab);
                      },
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Stack(children: [
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: context.fg.withOpacity(.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon(n.cat))),
                          if (!n.read) Positioned(right: 0, top: 0, child: CircleAvatar(radius: 4, backgroundColor: context.fg)),
                        ]),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700))), Text(ago(n.time), style: TextStyle(fontSize: 11, color: context.mutedc))]),
                          Text(n.body, style: TextStyle(color: context.mutedc, fontSize: 13)),
                        ])),
                      ]),
                    ),
                ]),
        ),
      ]),
    );
  }
}

// ───────────── Chats ─────────────
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), actions: [
        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => askForm(context, 'New message', ['Person name'], (v) => ifFilled(v[0], () => push(context, ChatScreen(s.startChat(v[0])))))),
      ]),
      body: s.chats.isEmpty
          ? const Empty(Icons.chat_bubble_outline, 'No conversations yet.')
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final c in s.chats)
                Box(
                  onTap: () => push(context, ChatScreen(c)),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: context.linec, child: Text(c.name[0].toUpperCase())),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(c.messages.isEmpty ? 'Say hello' : c.messages.last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.mutedc, fontSize: 12)),
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
    final s = S(context);
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
                  decoration: BoxDecoration(color: m.mine ? context.fg : context.cardc, borderRadius: BorderRadius.circular(16), border: m.mine ? null : Border.all(color: context.linec)),
                  child: Text(m.text, style: TextStyle(color: m.mine ? context.bgc : context.fg)),
                ),
              ),
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: t, decoration: dec(context, 'Message'))),
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

// ───────────── Settings ─────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    Widget head(String t) => Padding(padding: const EdgeInsets.only(top: 14, bottom: 8), child: Text(t.toUpperCase(), style: TextStyle(fontSize: 11.5, letterSpacing: 1.2, color: context.mutedc)));
    Widget item(IconData i, String t, VoidCallback f) => Box(onTap: f, child: Row(children: [Icon(i, size: 20), const SizedBox(width: 12), Expanded(child: Text(t)), Icon(Icons.chevron_right, color: context.mutedc)]));
    Widget sw(String t, bool v, ValueChanged<bool> f) => SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t), value: v, onChanged: f);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Box(
          child: Row(children: [
            CircleAvatar(radius: 26, backgroundColor: context.linec, child: Text((s.name ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 22))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)), Text(s.email ?? '', style: TextStyle(color: context.mutedc, fontSize: 12.5)), Text(s.role ?? '', style: TextStyle(color: context.mutedc, fontSize: 12))])),
          ]),
        ),
        head('Appearance'),
        Box(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined, size: 18), label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined, size: 18), label: Text('Dark')),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest_outlined, size: 18), label: Text('System')),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => s.setTheme(v.first),
              ),
            ),
            sw('Dark mode', s.themeMode == ThemeMode.dark || (s.themeMode == ThemeMode.system && context.isDark), (v) => s.setTheme(v ? ThemeMode.dark : ThemeMode.light)),
          ]),
        ),
        head('Account'),
        item(Icons.person_outline, 'Edit name, phone and email', () => askForm(context, 'Account', ['Full name', 'Email', 'Phone'], (v) {
              if (v[0].isNotEmpty) s.name = v[0];
              if (v[1].contains('@')) s.email = v[1].toLowerCase();
              s.phone = v[2];
              s.change();
            }, initial: [s.name ?? '', s.email ?? '', s.phone ?? ''])),
        item(Icons.lock_outline, 'Change password', () {
          final o = TextEditingController(), n = TextEditingController();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Change password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                Field(o, 'Current password', obscure: true),
                Field(n, 'New password', obscure: true, hint: '8+ characters with a number'),
                Btn('Update password', onTap: () {
                  final err = s.changePassword(o.text, n.text);
                  Navigator.pop(ctx);
                  snack(context, err ?? 'Password updated');
                }),
              ]),
            ),
          );
        }),
        head('Privacy'),
        Box(child: sw('Show me as available for work', s.available, (v) {
          s.available = v;
          s.change();
        })),
        head('Notifications'),
        Box(
          child: Column(children: [
            sw('Job alerts', s.notifJobs, (v) {
              s.notifJobs = v;
              s.change();
            }),
            sw('Application updates', s.notifApplications, (v) {
              s.notifApplications = v;
              s.change();
            }),
            sw('Messages', s.notifMessages, (v) {
              s.notifMessages = v;
              s.change();
            }),
          ]),
        ),
        item(Icons.notifications_none, 'View notifications', () => push(context, const NotificationsScreen())),
        item(Icons.chat_bubble_outline, 'Messages', () => push(context, const ChatsScreen())),
        head('About'),
        Box(child: Row(children: [const Icon(Icons.info_outline, size: 20), const SizedBox(width: 12), const Expanded(child: Text('sytadell')), Text('v1.1.0', style: TextStyle(color: context.mutedc))])),
        const SizedBox(height: 14),
        Btn('Sign out', filled: false, icon: Icons.logout, onTap: () {
          s.signOut();
          Navigator.popUntil(context, (r) => r.isFirst);
        }),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete account?'),
              content: const Text('This removes your account and all data from this device. This cannot be undone.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await s.deleteAccount();
                      if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst);
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          ),
          child: const Text('Delete account', style: TextStyle(color: Colors.redAccent)),
        ),
      ]),
    );
  }
}

// ───────────── AI Career Assistant ─────────────
class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  List<MapEntry<String, int>> skillGaps(AppState s) {
    final mine = s.skills.map((e) => e.toLowerCase()).toSet();
    final count = <String, int>{};
    for (final j in s.jobs) {
      for (final k in j.skills) {
        if (!mine.contains(k.toLowerCase())) count[k] = (count[k] ?? 0) + 1;
      }
    }
    return count.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final gaps = skillGaps(s);
    final ranked = s.jobs.where((j) => s.matchOf(j) != null).toList()..sort((a, b) => s.matchOf(b)!.compareTo(s.matchOf(a)!));
    final missing = s.missingProfile;

    Widget action(IconData i, String t, String d, List<String> Function() lines) => Box(
          onTap: () => infoSheet(context, t, lines()),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(i, size: 24),
            const SizedBox(height: 8),
            Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            Text(d, style: TextStyle(color: context.mutedc, fontSize: 11.5)),
          ]),
        );

    List<String> cvTips() {
      final t = <String>[];
      if (s.about.length < 100) t.add('Write a summary of at least 2-3 sentences (yours is ${s.about.isEmpty ? 'empty' : 'short'}).');
      if (s.exps.isEmpty) t.add('Add your work experience with measurable results.');
      if (s.exps.any((e) => e.details.isEmpty)) t.add('Add achievements to each role (e.g. "Improved load time by 40%").');
      if (s.skills.length < 5) t.add('List at least 5 relevant skills.');
      if (s.edus.isEmpty) t.add('Add your education.');
      if (s.certs.isEmpty && s.ports.isEmpty) t.add('Add certifications or portfolio projects.');
      return t.isEmpty ? ['Your CV covers all key sections. Review wording and keep it to one or two pages.'] : t;
    }

    List<String> interview() {
      final base = [
        'Tell me about yourself and why you want this role.',
        'Describe a challenging problem you solved and how.',
        'Tell me about a time you worked with a difficult teammate.',
        'Where do you see yourself in three years?',
        'What questions do you have for us?',
      ];
      final sk = s.skills.take(3).map((k) => 'Describe a project where you used $k. What would you do differently?');
      return [...base, ...sk];
    }

    return Scaffold(
      appBar: AppBar(title: const Heading('AI Career Assistant', 'Your personal guide to a better career.'), toolbarHeight: 70),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Box(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hi ${s.name ?? ''} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("I'm your AI Career Assistant. I analyse your profile and the jobs on sytadell to help you reach your goals faster."),
            const SizedBox(height: 12),
            TextField(
              onSubmitted: (_) => snack(context, 'Free-form AI chat needs an AI service to be connected. The quick actions below work now.'),
              decoration: dec(context, 'Ask me anything about your career...', prefix: const Icon(Icons.auto_awesome, size: 20), suffix: const Icon(Icons.send, size: 18)),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.35,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            action(Icons.description_outlined, 'Optimize My CV', 'Suggestions to make your CV stand out.', cvTips),
            action(Icons.track_changes, 'Find Skill Gaps', 'See what skills jobs ask for that you lack.', () => s.jobs.isEmpty ? ['No jobs are posted yet to compare against.'] : gaps.isEmpty ? ['You already cover every skill listed on current jobs.'] : gaps.take(8).map((e) => '${e.key} - requested in ${e.value} job${e.value == 1 ? '' : 's'}').toList()),
            action(Icons.groups_2_outlined, 'Interview Preparation', 'Practice questions for you.', interview),
            action(Icons.explore_outlined, 'Career Path Suggestions', 'Roles that fit your skills.', () => ranked.isEmpty ? ['Add skills to your profile and wait for jobs to be posted to see suggestions.'] : ranked.take(6).map((j) => '${j.title} at ${j.company} - ${s.matchOf(j)}% match').toList()),
            action(Icons.insights_outlined, 'Improve My Profile', 'Tips for employers.', () => missing.isEmpty ? ['Your profile is complete.'] : missing.map((m) => 'Add $m.').toList()),
            action(Icons.lightbulb_outline, 'Get Career Advice', 'General guidance.', () => ['Apply to roles where you match at least 70% of the skills.', 'Tailor your cover letter to each company.', 'Keep your portfolio current with your best 3-4 projects.', 'Follow up on applications after a week.']),
          ],
        ),
        const SizedBox(height: 10),
        const Text('AI Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Box(child: Row(children: [const Icon(Icons.work_outline), const SizedBox(width: 12), Expanded(child: Text(ranked.isEmpty ? 'Add skills to your profile to get job matches.' : "You're a great fit for ${ranked.first.title} (${s.matchOf(ranked.first)}% match)."))])),
        Box(child: Row(children: [const Icon(Icons.school_outlined), const SizedBox(width: 12), Expanded(child: Text(gaps.isEmpty ? 'No skill gaps found against current jobs.' : 'Consider learning ${gaps.first.key} - it is requested in ${gaps.first.value} current job${gaps.first.value == 1 ? '' : 's'}.'))])),
        Box(child: Row(children: [const Icon(Icons.trending_up), const SizedBox(width: 12), Expanded(child: Text(missing.isEmpty ? 'Your profile is complete. Keep applying!' : 'Next step: add ${missing.first}.'))])),
      ]),
    );
  }
}
