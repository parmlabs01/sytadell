import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'state.dart';
import 'widgets.dart';
import 'profile.dart';
import 'freelance.dart';
import 'misc.dart';
import 'talent.dart';
import 'banners.dart';
import 'learn.dart';

// ───────────── Home ─────────────
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final h = DateTime.now().hour;
    final greet = h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
    final first = (s.name ?? '').split(' ').first;
    final recs = [...s.jobs]..sort((a, b) => (s.matchOf(b) ?? -1).compareTo(s.matchOf(a) ?? -1));
    Widget quick(IconData i, String l, VoidCallback f) => Expanded(
          child: GestureDetector(
            onTap: f,
            child: Column(children: [
              Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: context.cardc, borderRadius: BorderRadius.circular(18), border: Border.all(color: context.linec)),
                  child: Icon(i)),
              const SizedBox(height: 6),
              Text(l, style: const TextStyle(fontSize: 11.5), textAlign: TextAlign.center),
            ]),
          ),
        );
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Logo(size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$greet,\n$first', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.15)),
            Text('Your next opportunity is closer than you think.', style: TextStyle(color: context.mutedc, fontSize: 12)),
          ]),
        ),
        IconButton(
            icon: Badge(isLabelVisible: s.notifications.any((n) => !n.read), child: const Icon(Icons.notifications_none)),
            onPressed: () => push(context, const NotificationsScreen())),
        IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () => s.setTab(4)),
      ]),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => s.setTab(1),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(border: Border.all(color: context.linec), borderRadius: BorderRadius.circular(26)),
          child: Row(children: [
            Icon(Icons.search, color: context.mutedc),
            const SizedBox(width: 10),
            Expanded(child: Text('Search jobs, skills, companies...', style: TextStyle(color: context.mutedc))),
            const Icon(Icons.tune, size: 20),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Pill('Jobs', icon: Icons.work_outline, onTap: () => s.setTab(1)),
          Pill('Freelance', icon: Icons.laptop_mac, onTap: () => push(context, const FreelanceScreen())),
          Pill('Hire Talent', icon: Icons.groups_2_outlined, onTap: () => push(context, const EmployerScreen())),
          Pill('Learn', icon: Icons.school_outlined, onTap: () => s.setTab(3)),
        ]),
      ),
      const SizedBox(height: 12),
      Box(
        onTap: () => s.setTab(4),
        child: Row(children: [
          Ring(s.completion, '${(s.completion * 100).round()}%', size: 62),
          const SizedBox(width: 14),
          const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Complete your profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 2),
            Text('A complete profile gets you more views and better matches.', style: TextStyle(fontSize: 12.5)),
          ])),
          const Icon(Icons.chevron_right),
        ]),
      ),
      const FeaturedCarousel(),
      const SizedBox(height: 6),
      Row(children: [
        quick(Icons.search, 'Find Jobs', () => s.setTab(1)),
        quick(Icons.laptop_mac, 'Freelance', () => push(context, const FreelanceScreen())),
        quick(Icons.groups_2_outlined, 'Hire Talent', () => push(context, const EmployerScreen())),
        quick(Icons.school_outlined, 'Learn', () => s.setTab(3)),
        quick(Icons.description_outlined, 'Build CV', () => push(context, const CvBuilderScreen())),
      ]),
      const SizedBox(height: 22),
      Row(children: [
        const Expanded(child: Text('Recommended for you', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
        TextButton(onPressed: () => s.setTab(1), child: const Text('See all →')),
      ]),
      if (recs.isEmpty)
        const SizedBox(height: 180, child: Empty(Icons.work_outline, 'No jobs have been posted yet. Employers can post roles from the Hire Talent dashboard.'))
      else
        ...recs.take(5).map((j) => JobTile(j)),
    ]);
  }
}

class JobTile extends StatelessWidget {
  final Job job;
  const JobTile(this.job, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final m = s.matchOf(job);
    final saved = s.savedJobs.contains(job.id);
    final extra = job.skills.length > 2 ? job.skills.length - 2 : 0;
    return Box(
      onTap: () => push(context, JobDetails(job)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: context.fg.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
            child: Text(job.company.isEmpty ? '?' : job.company[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job.company, style: TextStyle(color: context.mutedc, fontSize: 12.5)),
            Text(job.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${job.location}  ·  ${job.mode}', style: TextStyle(color: context.mutedc, fontSize: 12.5)),
            Text(job.salary, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(children: [
              Pill(job.type, small: true),
              ...job.skills.take(2).map((e) => Pill(e, small: true)),
              if (extra > 0) Pill('$extra+ more', small: true),
            ]),
            Text('Posted ${ago(job.posted)}', style: TextStyle(color: context.mutedc, fontSize: 11)),
          ]),
        ),
        Column(children: [
          GestureDetector(onTap: () => s.toggleSaveJob(job), child: Icon(saved ? Icons.bookmark : Icons.bookmark_border)),
          const SizedBox(height: 10),
          if (m != null) ...[Ring(m / 100, '$m%', size: 48), const Text('Match', style: TextStyle(fontSize: 11))],
        ]),
      ]),
    );
  }
}

// ───────────── Find Jobs ─────────────
class JobsTab extends StatefulWidget {
  const JobsTab({super.key});
  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  String q = '', loc = '', chip = 'All Jobs', sort = 'Most Relevant';
  String? exp, company;
  bool savedOnly = false;
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    var list = s.jobs.where((j) {
      final t = '${j.title} ${j.company} ${j.about} ${j.skills.join(' ')}'.toLowerCase();
      final l = '${j.location} ${j.mode}'.toLowerCase();
      final chipOk = chip == 'All Jobs' || (chip == 'Remote' ? j.mode == 'Remote' : j.type == chip);
      return t.contains(q.toLowerCase()) &&
          l.contains(loc.toLowerCase()) &&
          chipOk &&
          (exp == null || j.experience == exp) &&
          (company == null || j.company == company) &&
          (!savedOnly || s.savedJobs.contains(j.id));
    }).toList();
    if (sort == 'Newest') {
      list.sort((a, b) => b.posted.compareTo(a.posted));
    } else {
      list.sort((a, b) => (s.matchOf(b) ?? -1).compareTo(s.matchOf(a) ?? -1));
    }
    final companies = s.jobs.map((e) => e.company).toSet().toList();
    final exps = s.jobs.map((e) => e.experience).where((e) => e.isNotEmpty).toSet().toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
        child: Row(children: [
          const Expanded(child: Heading('Find Jobs', 'Great opportunities. Better tomorrows.')),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => push(context, const NotificationsScreen())),
          IconButton(icon: Icon(savedOnly ? Icons.bookmark : Icons.bookmark_border), onPressed: () => setState(() => savedOnly = !savedOnly)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(children: [
          TextField(onChanged: (v) => setState(() => q = v), decoration: dec(context, 'Job title, skill, company or keyword...', prefix: const Icon(Icons.search, size: 20))),
          const SizedBox(height: 10),
          TextField(onChanged: (v) => setState(() => loc = v), decoration: dec(context, 'Location (e.g. Lagos, Remote)', prefix: const Icon(Icons.location_on_outlined, size: 20))),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final c in ['All Jobs', 'Full-time', 'Part-time', 'Contract', 'Internship', 'Remote']) Pill(c, selected: chip == c, onTap: () => setState(() => chip = c)),
            ]),
          ),
          Row(children: [
            Expanded(child: Select(value: exp, hint: 'Experience', items: exps, onChanged: (v) => setState(() => exp = v))),
            const SizedBox(width: 8),
            Expanded(child: Select(value: company, hint: 'Company', items: companies, onChanged: (v) => setState(() => company = v))),
            IconButton(icon: const Icon(Icons.filter_alt_off_outlined), tooltip: 'Clear filters', onPressed: () => setState(() => exp = company = null)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('${list.length} jobs found', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            PopupMenuButton<String>(
              onSelected: (v) => setState(() => sort = v),
              itemBuilder: (_) => ['Most Relevant', 'Newest'].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
              child: Row(children: [const Icon(Icons.swap_vert, size: 18), const SizedBox(width: 4), Text(sort, style: const TextStyle(fontSize: 13)), const Icon(Icons.expand_more, size: 18)]),
            ),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? const Empty(Icons.search_off, 'No jobs match yet.')
            : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: list.map((j) => JobTile(j)).toList()),
      ),
    ]);
  }
}

// ───────────── Job details ─────────────
class JobDetails extends StatelessWidget {
  final Job job;
  const JobDetails(this.job, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final applied = s.hasApplied(job);
    final saved = s.savedJobs.contains(job.id);
    final m = s.matchOf(job);
    Widget bullets(List<String> l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: l.map((r) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Text('•  $r', style: const TextStyle(height: 1.35)))).toList());
    Widget info(String t, String v, String sub) => Expanded(
          child: Box(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: TextStyle(fontSize: 11, color: context.mutedc)),
                Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(sub, style: TextStyle(fontSize: 11, color: context.mutedc)),
              ])),
        );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back to search', style: TextStyle(fontSize: 14)),
        actions: [
          IconButton(icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border), onPressed: () => s.toggleSaveJob(job)),
          IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '${job.title} at ${job.company} (${job.location}) - ${job.salary}'));
                snack(context, 'Job details copied');
              }),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job.company, style: TextStyle(color: context.mutedc)),
            const SizedBox(height: 4),
            Text(job.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.05)),
          ])),
          if (m != null) Column(children: [Ring(m / 100, '$m%', size: 76), const Text('Match')]),
        ]),
        const SizedBox(height: 12),
        Text('${job.location}  ·  ${job.mode}', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text('${job.type}   ${job.experience.isEmpty ? '' : '·  ${job.experience} experience   '}·  ${job.salary}', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(children: job.skills.map((e) => Pill(e)).toList()),
        const SizedBox(height: 8),
        Section(Icons.description_outlined, 'About the role', child: Text(job.about.isEmpty ? 'No description provided.' : job.about, style: const TextStyle(height: 1.4))),
        if (job.responsibilities.isNotEmpty) Section(Icons.track_changes, 'Key responsibilities', child: bullets(job.responsibilities)),
        if (job.requirements.isNotEmpty) Section(Icons.verified_user_outlined, 'Requirements', child: bullets(job.requirements)),
        Row(children: [
          info('Estimated salary', job.salary, 'per month'),
          info('Company', job.company, 'Employer'),
          info('Work type', job.type, '(${job.mode})'),
        ]),
        if (job.skills.isNotEmpty) Section(Icons.sell_outlined, 'Required skills', child: Wrap(children: job.skills.map((e) => Pill(e)).toList())),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Btn(saved ? 'Saved' : 'Save job', filled: false, icon: saved ? Icons.bookmark : Icons.bookmark_border, onTap: () => s.toggleSaveJob(job))),
            const SizedBox(width: 10),
            Expanded(child: Btn(applied ? 'Applied' : 'Apply now', icon: Icons.send, onTap: applied ? null : () => push(context, ApplyScreen(job)))),
          ]),
        ),
      ),
    );
  }
}

// ───────────── Apply ─────────────
class ApplyScreen extends StatefulWidget {
  final Job job;
  const ApplyScreen(this.job, {super.key});
  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final cover = TextEditingController();
  String? fileName, fileSize, notice, remote, salary;
  bool useBuilt = false, agree = false, loaded = false;

  void loadDraft() {
    if (loaded) return;
    loaded = true;
    final d = S(context).drafts[widget.job.id];
    if (d != null) {
      cover.text = d['cover'] ?? '';
      notice = d['notice'];
      remote = d['remote'];
      salary = d['salary'];
    }
  }

  Future<void> pick() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (r == null || r.files.isEmpty) return;
    final f = r.files.first;
    if (f.size > 5 * 1024 * 1024) {
      if (mounted) snack(context, 'File is larger than 5MB');
      return;
    }
    setState(() {
      fileName = f.name;
      fileSize = '${(f.size / 1048576).toStringAsFixed(1)} MB';
      useBuilt = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    loadDraft();
    final s = S(context);
    final j = widget.job;
    final hasBuilt = s.exps.isNotEmpty || s.skills.isNotEmpty;
    final cvName = useBuilt ? 'Sytadell CV (${s.cvTemplate})' : fileName;
    Widget q(IconData i, String t, String? v, List<String> items, ValueChanged<String?> f) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(i, size: 20),
            const SizedBox(width: 12),
            Expanded(flex: 5, child: Text(t, style: const TextStyle(fontSize: 13.5))),
            Expanded(flex: 4, child: Select(value: v, hint: 'Select', items: items, onChanged: f)),
          ]),
        );
    return Scaffold(
      appBar: AppBar(title: Text('Apply for Job\n${j.title} · ${j.company}', style: const TextStyle(fontSize: 15))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          for (final (i, t) in ['Application', 'Review', 'Interview', 'Offer'].indexed)
            Expanded(
              child: Column(children: [
                CircleAvatar(radius: 14, backgroundColor: i == 0 ? context.fg : Colors.transparent, child: Text('${i + 1}', style: TextStyle(fontSize: 12, color: i == 0 ? context.bgc : context.fg))),
                const SizedBox(height: 4),
                Text(t, style: const TextStyle(fontSize: 11.5)),
              ]),
            ),
        ]),
        const SizedBox(height: 18),
        Box(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(j.company, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${j.location} (${j.mode})  ·  ${j.type}  ·  ${j.salary}', style: TextStyle(color: context.mutedc, fontSize: 12.5)),
          Text('Posted ${ago(j.posted)}', style: TextStyle(color: context.mutedc, fontSize: 12)),
        ])),
        const Text('1  Your CV / Resume', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        Text('Upload your most recent CV (PDF, DOC or DOCX), max 5MB.', style: TextStyle(color: context.mutedc, fontSize: 12.5)),
        const SizedBox(height: 10),
        Box(
          onTap: pick,
          child: Row(children: [
            const Icon(Icons.cloud_upload_outlined, size: 30),
            const SizedBox(width: 12),
            const Expanded(child: Text('Tap to upload your CV')),
            const Pill('Choose file'),
          ]),
        ),
        if (fileName != null && !useBuilt)
          Box(
              child: Row(children: [
            const Icon(Icons.insert_drive_file_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text('$fileName  ·  $fileSize')),
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => fileName = null)),
          ])),
        if (hasBuilt)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: useBuilt,
            onChanged: (v) => setState(() => useBuilt = v ?? false),
            title: const Text('Use the CV built from my profile', style: TextStyle(fontSize: 13.5)),
          ),
        const SizedBox(height: 14),
        const Text('2  Cover Letter (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Field(cover, '', hint: 'Introduce yourself, highlight your key skills and explain why you want to work with ${j.company}.', maxLines: 5, maxLength: 500),
        const Text('3  Additional Questions (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Box(
            child: Column(children: [
          q(Icons.work_outline, 'What is your current notice period?', notice, ['Immediately', '1 week', '2 weeks', '1 month', '2+ months'], (v) => setState(() => notice = v)),
          q(Icons.code, 'Are you able to work remotely?', remote, ['Yes', 'No', 'Hybrid only'], (v) => setState(() => remote = v)),
          q(Icons.star_border, 'What is your expected salary range?', salary, ['Below \$500', '\$500 - \$1,000', '\$1,000 - \$2,000', '\$2,000 - \$3,500', '\$3,500+'], (v) => setState(() => salary = v)),
        ])),
        const Text('4  Review & Submit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: agree,
          onChanged: (v) => setState(() => agree = v ?? false),
          title: const Text('I agree to the terms and conditions and confirm that all information provided is true and correct.', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 8),
        Btn('Submit Application', icon: Icons.send, onTap: () {
          if (cvName == null) return snack(context, 'Please upload or select a CV');
          if (!agree) return snack(context, 'Please accept the terms to continue');
          s.apply(j, cvName, cover.text.trim(), {'Notice period': notice ?? '', 'Remote': remote ?? '', 'Expected salary': salary ?? ''});
          Navigator.pop(context);
          snack(context, 'Application submitted');
        }),
        Center(
          child: TextButton(
            onPressed: () {
              s.drafts[j.id] = {'cover': cover.text, 'notice': notice ?? '', 'remote': remote ?? '', 'salary': salary ?? ''};
              Navigator.pop(context);
              snack(context, 'Draft saved');
            },
            child: const Text('Save and finish later', style: TextStyle(decoration: TextDecoration.underline)),
          ),
        ),
      ]),
    );
  }
}

// ───────────── Applications ─────────────
class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String f = 'All';
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final all = s.applications;
    final active = all.where((a) => a.status != 'Archived').toList();
    int count(String t) {
      switch (t) {
        case 'All':
          return active.length;
        case 'Applied':
          return all.where((a) => a.status == 'Applied' || a.status == 'Under review').length;
        case 'Interviews':
          return all.where((a) => a.status == 'Interview').length;
        case 'Offers':
          return all.where((a) => a.status == 'Offer').length;
        default:
          return all.where((a) => a.status == 'Archived').length;
      }
    }

    final list = all.where((a) {
      switch (f) {
        case 'All':
          return a.status != 'Archived';
        case 'Applied':
          return a.status == 'Applied' || a.status == 'Under review';
        case 'Interviews':
          return a.status == 'Interview';
        case 'Offers':
          return a.status == 'Offer';
        default:
          return a.status == 'Archived';
      }
    }).toList();
    final prog = (active.length / s.applyGoal).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Heading('My Applications', 'Track your applications and stay updated.'), toolbarHeight: 70),
      body: Column(children: [
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: ['All', 'Applied', 'Interviews', 'Offers', 'Archived'].map((x) => Pill('$x  ${count(x)}', selected: f == x, onTap: () => setState(() => f = x))).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Box(
            onTap: () => askForm(context, 'Application goal', ['Number of jobs to apply to'], (v) {
              final n = int.tryParse(v[0]);
              if (n != null && n > 0) {
                s.applyGoal = n;
                s.change();
              }
            }, initial: ['${s.applyGoal}']),
            child: Row(children: [
              const Icon(Icons.auto_awesome),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Application Progress', style: TextStyle(fontWeight: FontWeight.w700)),
                Text("You've applied to ${active.length} jobs.", style: TextStyle(color: context.mutedc, fontSize: 12.5)),
              ])),
              Ring(prog, '${(prog * 100).round()}%'),
              const SizedBox(width: 10),
              Text('Goal\nApply to ${s.applyGoal} jobs', style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Empty(Icons.assignment_outlined, 'No applications here yet.')
              : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
                  for (final a in list)
                    Box(
                      onTap: () => push(context, JobDetails(a.job)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(a.job.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text(a.job.company, style: TextStyle(color: context.mutedc)),
                            const SizedBox(height: 4),
                            Text('${a.job.location}  ·  ${a.job.type}  ·  Applied ${ago(a.date)}', style: TextStyle(color: context.mutedc, fontSize: 12)),
                            const SizedBox(height: 6),
                            Wrap(children: a.job.skills.take(4).map((e) => Pill(e, small: true)).toList()),
                          ]),
                        ),
                        Column(children: [
                          PopupMenuButton<String>(
                            onSelected: (v) => s.setStatus(a, v),
                            itemBuilder: (_) => kStatuses.map((x) => PopupMenuItem(value: x, child: Text(x))).toList(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: context.linec)),
                              child: Text(a.status, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                          if (s.matchOf(a.job) != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Match ${s.matchOf(a.job)}%', style: TextStyle(fontSize: 11.5, color: context.mutedc))),
                        ]),
                      ]),
                    ),
                ]),
        ),
      ]),
    );
  }
}

// ───────────── Post job ─────────────
class PostJobSheet extends StatefulWidget {
  const PostJobSheet({super.key});
  @override
  State<PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends State<PostJobSheet> {
  final t = TextEditingController(), co = TextEditingController(), loc = TextEditingController(), sal = TextEditingController();
  final exp = TextEditingController(), about = TextEditingController(), resp = TextEditingController(), req = TextEditingController(), sk = TextEditingController();
  String type = 'Full-time', mode = 'On-site';
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Post a job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Field(t, 'Job title'),
            Field(co, 'Company'),
            Field(loc, 'Location'),
            Field(sal, 'Salary', hint: '\$1,200 - \$2,000 / month'),
            Field(exp, 'Experience', hint: '3+ years'),
            Field(sk, 'Required skills (comma separated)'),
            Field(about, 'About the role', maxLines: 3),
            Field(resp, 'Key responsibilities (one per line)', maxLines: 3),
            Field(req, 'Requirements (one per line)', maxLines: 3),
            Wrap(children: [for (final x in ['Full-time', 'Part-time', 'Contract', 'Internship']) Pill(x, selected: type == x, onTap: () => setState(() => type = x))]),
            Wrap(children: [for (final x in ['On-site', 'Remote', 'Hybrid']) Pill(x, selected: mode == x, onTap: () => setState(() => mode = x))]),
            const SizedBox(height: 14),
            Btn('Publish', onTap: () {
              if (t.text.trim().isEmpty || co.text.trim().isEmpty) return snack(context, 'Title and company are required');
              S(context).postJob(Job(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: t.text.trim(),
                company: co.text.trim(),
                location: loc.text.trim().isEmpty ? 'Anywhere' : loc.text.trim(),
                type: type,
                mode: mode,
                experience: exp.text.trim(),
                salary: sal.text.trim().isEmpty ? 'Not disclosed' : sal.text.trim(),
                about: about.text.trim(),
                skills: splitList(sk.text, ','),
                responsibilities: splitList(resp.text, '\n'),
                requirements: splitList(req.text, '\n'),
                posted: DateTime.now(),
              ));
              Navigator.pop(context);
            }),
          ]),
        ),
      );
}
