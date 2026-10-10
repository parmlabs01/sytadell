import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'state.dart';
import 'widgets.dart';
import 'jobs.dart';
import 'freelance.dart';
import 'misc.dart';
import 'talent.dart';

// ───────────── Editors shared by Profile and CV builder ─────────────
void editBasics(BuildContext c) {
  final s = S(c);
  askForm(c, 'Edit profile', ['Full name', 'Headline (e.g. Full Stack Developer)', 'Location', 'Phone', 'Website / portfolio', 'Years of experience', 'About me'],
      (v) {
    if (v[0].isNotEmpty) s.name = v[0];
    s.headline = v[1];
    s.location = v[2];
    s.phone = v[3];
    s.website = v[4];
    s.years = v[5];
    s.about = v[6];
    s.change();
  }, initial: [s.name ?? '', s.headline, s.location, s.phone ?? '', s.website, s.years, s.about], multiline: {6});
}

void addExp(BuildContext c) => askForm(c, 'Add experience', ['Role', 'Company', 'Period (e.g. 2021 - Present)', 'What you did'],
    (v) => ifFilled(v[0], () => S(c).add(S(c).exps, Exp(v[0], v[1], v[2], v[3]))), multiline: {3});
void addEdu(BuildContext c) =>
    askForm(c, 'Add education', ['Degree', 'Institution', 'Period'], (v) => ifFilled(v[0], () => S(c).add(S(c).edus, Edu(v[0], v[1], v[2]))));
void addPort(BuildContext c) =>
    askForm(c, 'Add project', ['Project title', 'Type (e.g. Web Application)'], (v) => ifFilled(v[0], () => S(c).add(S(c).ports, Port(v[0], v[1]))));
void addAch(BuildContext c) =>
    askForm(c, 'Add achievement', ['Title', 'Details'], (v) => ifFilled(v[0], () => S(c).add(S(c).achs, Ach(v[0], v[1]))));
void addCert(BuildContext c) =>
    askForm(c, 'Add certification', ['Certification'], (v) => ifFilled(v[0], () => S(c).add(S(c).certs, v[0])));
void editSkills(BuildContext c) {
  final s = S(c);
  askForm(c, 'Edit skills', ['Skills (comma separated)'], (v) {
    s.skills = splitList(v[0], ',');
    s.change();
  }, initial: [s.skills.join(', ')], multiline: {0});
}

// ───────────── Profile tab ─────────────
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final pct = (s.completion * 100).round();
    Widget stat(String n, String l) => Expanded(
        child: Column(children: [
      Text(n, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
      Text(l, style: TextStyle(color: context.mutedc, fontSize: 11.5), textAlign: TextAlign.center),
    ]));
    Widget del(VoidCallback f) => GestureDetector(onTap: f, child: Icon(Icons.close, size: 16, color: context.mutedc));
    Widget link(IconData i, String l, Widget p) => Box(
        onTap: () => push(context, p),
        child: Row(children: [Icon(i, size: 20), const SizedBox(width: 12), Expanded(child: Text(l)), Icon(Icons.chevron_right, color: context.mutedc)]));
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        const Expanded(child: Heading('Professional Profile', 'Showcase your skills, experience and achievements.')),
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => push(context, const SettingsScreen())),
      ]),
      const SizedBox(height: 14),
      Box(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 38, backgroundColor: context.linec, child: Text((s.name ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 30))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name ?? '', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              Text(s.headline.isEmpty ? (s.role ?? '') : s.headline, style: TextStyle(color: context.mutedc)),
              const SizedBox(height: 4),
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                if (s.location.isNotEmpty) Text('${s.location}   ', style: const TextStyle(fontSize: 12.5)),
                Icon(Icons.circle, size: 9, color: s.available ? Colors.green : context.mutedc),
                Text(s.available ? '  Available for work' : '  Not available', style: const TextStyle(fontSize: 12.5)),
              ]),
              const SizedBox(height: 10),
              Pill('Edit Profile', icon: Icons.edit_outlined, onTap: () => editBasics(context)),
            ]),
          ),
        ]),
      ),
      Box(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Row(children: [
            stat(s.years.isEmpty ? '-' : s.years, 'Years Experience'),
            stat('${s.ports.length}', 'Projects'),
            stat('${s.certs.length}', 'Certifications'),
            stat('$pct%', 'Profile Complete'),
          ]),
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 0), child: LinearProgressIndicator(value: s.completion, minHeight: 4, color: Colors.green, backgroundColor: context.linec)),
        ]),
      ),
      Section(Icons.person_outline, 'About Me', action: 'Edit', onAction: () => editBasics(context), child: Text(s.about.isEmpty ? 'Tell employers about yourself.' : s.about, style: const TextStyle(height: 1.4))),
      Section(Icons.call_outlined, 'Contact Information',
          child: Wrap(spacing: 14, runSpacing: 6, children: [
            if ((s.email ?? '').isNotEmpty) Text('✉ ${s.email}', style: const TextStyle(fontSize: 13)),
            if ((s.phone ?? '').isNotEmpty) Text('☎ ${s.phone}', style: const TextStyle(fontSize: 13)),
            if (s.website.isNotEmpty) Text('🔗 ${s.website}', style: const TextStyle(fontSize: 13)),
          ])),
      Section(Icons.work_outline, 'Work Experience', action: '+ Add New', onAction: () => addExp(context),
          child: s.exps.isEmpty
              ? Text('No experience added.', style: TextStyle(color: context.mutedc))
              : Column(children: [
                  for (final e in s.exps)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.role, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${e.company}  ·  ${e.period}', style: TextStyle(color: context.mutedc, fontSize: 12.5)),
                          if (e.details.isNotEmpty) Text(e.details, style: const TextStyle(fontSize: 13, height: 1.35)),
                        ])),
                        del(() => s.remove(s.exps, e)),
                      ]),
                    ),
                ])),
      Section(Icons.school_outlined, 'Education', action: '+ Add New', onAction: () => addEdu(context),
          child: s.edus.isEmpty
              ? Text('No education added.', style: TextStyle(color: context.mutedc))
              : Column(children: [
                  for (final e in s.edus)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.degree, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${e.school}  ·  ${e.period}', style: TextStyle(color: context.mutedc, fontSize: 12.5)),
                        ])),
                        del(() => s.remove(s.edus, e)),
                      ]),
                    ),
                ])),
      Section(Icons.settings_suggest_outlined, 'Skills', action: 'Edit', onAction: () => editSkills(context),
          child: s.skills.isEmpty ? Text('No skills added.', style: TextStyle(color: context.mutedc)) : Wrap(children: s.skills.map((e) => Pill(e)).toList())),
      Section(Icons.image_outlined, 'Portfolio', action: '+ Add New', onAction: () => addPort(context),
          child: s.ports.isEmpty
              ? Text('No projects added.', style: TextStyle(color: context.mutedc))
              : Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final p in s.ports)
                    Container(
                      width: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(border: Border.all(color: context.linec), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2),
                          Text(p.type, style: TextStyle(color: context.mutedc, fontSize: 11.5)),
                        ])),
                        del(() => s.remove(s.ports, p)),
                      ]),
                    ),
                ])),
      Section(Icons.verified_outlined, 'Certifications', action: '+ Add New', onAction: () => addCert(context),
          child: s.certs.isEmpty
              ? Text('No certifications added.', style: TextStyle(color: context.mutedc))
              : Column(children: [for (final c in s.certs) Row(children: [Expanded(child: Text(c)), del(() => s.remove(s.certs, c))])])),
      Section(Icons.emoji_events_outlined, 'Achievements', action: '+ Add New', onAction: () => addAch(context),
          child: s.achs.isEmpty
              ? Text('No achievements added.', style: TextStyle(color: context.mutedc))
              : Column(children: [
                  for (final a in s.achs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (a.sub.isNotEmpty) Text(a.sub, style: TextStyle(color: context.mutedc, fontSize: 12)),
                        ])),
                        del(() => s.remove(s.achs, a)),
                      ]),
                    ),
                ])),
      const SizedBox(height: 6),
      link(Icons.description_outlined, 'CV Builder', const CvBuilderScreen()),
      link(Icons.assignment_outlined, 'My Applications', const ApplicationsScreen()),
      link(Icons.auto_awesome, 'AI Career Assistant', const AiAssistantScreen()),
      link(Icons.laptop_mac, 'Freelance Marketplace', const FreelanceScreen()),
      link(Icons.groups_2_outlined, 'Employer dashboard', const EmployerScreen()),
      link(Icons.chat_bubble_outline, 'Messages', const ChatsScreen()),
    ]);
  }
}

// ───────────── CV ─────────────
bool _twoCol(String t) => t == 'Modern Pro' || t == 'Creative' || t == 'Tech';

class CvPaper extends StatelessWidget {
  final AppState s;
  const CvPaper(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    final accent = Color(kTemplates[s.cvTemplate] ?? 0xFF2563EB);
    const ink = Color(0xFF1B1B1B);
    Widget h(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(t.toUpperCase(), style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 10.5, letterSpacing: 1)));
    Widget tx(String t, {bool b = false, double sz = 10.5, Color c = ink}) => Text(t, style: TextStyle(color: c, fontSize: sz, fontWeight: b ? FontWeight.w700 : FontWeight.w400, height: 1.3));
    final exp = [
      if (s.exps.isNotEmpty) h('Experience'),
      for (final e in s.exps) ...[tx(e.role, b: true), tx('${e.company}  ·  ${e.period}', c: Colors.black54), if (e.details.isNotEmpty) tx(e.details), const SizedBox(height: 6)],
      if (s.edus.isNotEmpty) h('Education'),
      for (final e in s.edus) ...[tx(e.degree, b: true), tx('${e.school}  ·  ${e.period}', c: Colors.black54), const SizedBox(height: 6)],
    ];
    final side = [
      if (s.skills.isNotEmpty) h('Skills'),
      if (s.skills.isNotEmpty) tx(s.skills.join('  ·  ')),
      if (s.ports.isNotEmpty) h('Projects'),
      for (final p in s.ports) ...[tx(p.title, b: true), tx(p.type, c: Colors.black54), const SizedBox(height: 4)],
      if (s.certs.isNotEmpty) h('Certifications'),
      for (final c in s.certs) tx(c),
      if (s.achs.isNotEmpty) h('Achievements'),
      for (final a in s.achs) tx('${a.title}${a.sub.isEmpty ? '' : ' (${a.sub})'}'),
    ];
    final header = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      tx(s.name ?? '', b: true, sz: 20),
      if (s.headline.isNotEmpty) tx(s.headline, b: true, sz: 12, c: accent),
      const SizedBox(height: 4),
      tx([s.phone, s.email, s.location, s.website].where((e) => e != null && e.isNotEmpty).join('   ·   '), c: Colors.black54, sz: 9.5),
      if (s.about.isNotEmpty) ...[const SizedBox(height: 6), tx(s.about)],
    ]);
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header,
        const Divider(),
        _twoCol(s.cvTemplate)
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 6, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: exp)),
                const SizedBox(width: 14),
                Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: side)),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...exp, ...side]),
      ]),
    );
  }
}

Future<Uint8List> buildCvPdf(AppState s) async {
  final accent = PdfColor.fromInt(kTemplates[s.cvTemplate] ?? 0xFF2563EB);
  pw.Widget h(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 4),
      child: pw.Text(t.toUpperCase(), style: pw.TextStyle(color: accent, fontWeight: pw.FontWeight.bold, fontSize: 11)));
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    margin: const pw.EdgeInsets.all(36),
    build: (_) => [
      pw.Text(s.name ?? '', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      if (s.headline.isNotEmpty) pw.Text(s.headline, style: pw.TextStyle(fontSize: 13, color: accent, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.Text([s.phone, s.email, s.location, s.website].where((e) => e != null && e.isNotEmpty).join('  |  '), style: const pw.TextStyle(fontSize: 9.5)),
      if (s.about.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(top: 8), child: pw.Text(s.about, style: const pw.TextStyle(fontSize: 10.5))),
      pw.Divider(),
      if (s.exps.isNotEmpty) h('Experience'),
      for (final e in s.exps)
        pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(e.role, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${e.company} - ${e.period}', style: const pw.TextStyle(fontSize: 10)),
              if (e.details.isNotEmpty) pw.Text(e.details, style: const pw.TextStyle(fontSize: 10)),
            ])),
      if (s.edus.isNotEmpty) h('Education'),
      for (final e in s.edus) pw.Text('${e.degree}, ${e.school} (${e.period})', style: const pw.TextStyle(fontSize: 10.5)),
      if (s.skills.isNotEmpty) h('Skills'),
      if (s.skills.isNotEmpty) pw.Text(s.skills.join(', '), style: const pw.TextStyle(fontSize: 10.5)),
      if (s.ports.isNotEmpty) h('Projects'),
      for (final p in s.ports) pw.Text('${p.title} (${p.type})', style: const pw.TextStyle(fontSize: 10.5)),
      if (s.certs.isNotEmpty) h('Certifications'),
      for (final c in s.certs) pw.Text(c, style: const pw.TextStyle(fontSize: 10.5)),
      if (s.achs.isNotEmpty) h('Achievements'),
      for (final a in s.achs) pw.Text('${a.title}${a.sub.isEmpty ? '' : ' - ${a.sub}'}', style: const pw.TextStyle(fontSize: 10.5)),
    ],
  ));
  return doc.save();
}

class CvBuilderScreen extends StatefulWidget {
  const CvBuilderScreen({super.key});
  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> {
  String group = 'All';
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final names = group == 'All' ? kTemplates.keys.toList() : kTemplateGroups[group]!;
    Widget row(IconData i, String t, String sub, VoidCallback f) => ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: Icon(i),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: f);
    Future<void> pdf(bool share) async {
      if (s.name == null) return;
      final bytes = await buildCvPdf(s);
      final name = '${(s.name ?? 'cv').replaceAll(' ', '_')}_CV.pdf';
      if (share) {
        await Printing.sharePdf(bytes: bytes, filename: name);
      } else {
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Heading('CV Builder', 'Create a professional CV, stand out, get hired.'), toolbarHeight: 70),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Box(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose a Template', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final g in ['All', ...kTemplateGroups.keys]) Pill(g, selected: group == g, onTap: () => setState(() => group = g))])),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final n in names)
                GestureDetector(
                  onTap: () {
                    s.cvTemplate = n;
                    s.change();
                  },
                  child: Container(
                    width: 92,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(children: [
                      Container(
                        height: 96,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: s.cvTemplate == n ? Colors.blueAccent : context.linec, width: s.cvTemplate == n ? 2.5 : 1)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(width: 50, height: 6, color: Color(kTemplates[n]!)),
                          const SizedBox(height: 5),
                          Container(width: 60, height: 3, color: Colors.black12),
                          const SizedBox(height: 3),
                          Container(width: 60, height: 3, color: Colors.black12),
                          const SizedBox(height: 3),
                          Container(width: 40, height: 3, color: Colors.black12),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      Text(n, style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
                ),
            ]),
          ),
        ])),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: CvPaper(s)),
        const SizedBox(height: 12),
        Box(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Customize Your CV', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          row(Icons.person_outline, 'Personal Info', 'Name, contact, headline', () => editBasics(context)),
          row(Icons.work_outline, 'Experience', 'Work history, roles, dates', () => addExp(context)),
          row(Icons.school_outlined, 'Education', 'Degrees, institutions', () => addEdu(context)),
          row(Icons.settings_suggest_outlined, 'Skills', 'Technical & soft skills', () => editSkills(context)),
          row(Icons.folder_open, 'Projects', 'Showcase your work', () => addPort(context)),
          row(Icons.verified_outlined, 'Certifications', 'Add credentials', () => addCert(context)),
          row(Icons.emoji_events_outlined, 'Achievements', 'Awards & recognitions', () => addAch(context)),
        ])),
        Box(
          onTap: () => push(context, Scaffold(appBar: AppBar(title: const Text('Preview')), body: ListView(padding: const EdgeInsets.all(16), children: [CvPaper(S(context))]))),
          child: const Row(children: [Icon(Icons.visibility_outlined), SizedBox(width: 12), Expanded(child: Text('Preview Your CV')), Icon(Icons.chevron_right)]),
        ),
        Row(children: [
          Expanded(flex: 3, child: Btn('Download CV (PDF)', icon: Icons.download, onTap: () => pdf(false))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: Btn('Share', filled: false, icon: Icons.share, onTap: () => pdf(true))),
        ]),
      ]),
    );
  }
}
