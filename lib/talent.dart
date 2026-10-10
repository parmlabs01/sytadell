import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';
import 'jobs.dart';

class EmployerScreen extends StatefulWidget {
  const EmployerScreen({super.key});
  @override
  State<EmployerScreen> createState() => _EmployerScreenState();
}

class _EmployerScreenState extends State<EmployerScreen> {
  String tab = 'Candidates';
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final ids = s.jobs.map((j) => j.id).toSet();
    final apps = s.applications.where((a) => ids.contains(a.job.id) && a.status != 'Archived').toList();
    int n(String st) => apps.where((a) => a.status == st).length;
    Widget stat(String v, String l) => Expanded(
        child: Box(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(children: [
              Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(l, style: TextStyle(color: context.mutedc, fontSize: 11.5), textAlign: TextAlign.center),
            ])));
    Widget body;
    if (tab == 'Candidates') {
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recent applicants', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (apps.isEmpty) const SizedBox(height: 180, child: Empty(Icons.people_outline, 'No applicants yet.')),
        for (final a in apps)
          Box(
            child: Row(children: [
              CircleAvatar(backgroundColor: context.linec, child: Text((s.name ?? '?')[0].toUpperCase())),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${s.headline.isEmpty ? 'Applicant' : s.headline}  ·  ${a.job.title}', style: TextStyle(color: context.mutedc, fontSize: 12)),
                  if (s.matchOf(a.job) != null) Text('${s.matchOf(a.job)}% match', style: const TextStyle(fontSize: 12)),
                ]),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => s.setStatus(a, v),
                itemBuilder: (_) => ['Under review', 'Shortlisted', 'Interview', 'Offer', 'Rejected'].map((x) => PopupMenuItem(value: x, child: Text(x))).toList(),
                child: Pill(a.status, small: true),
              ),
            ]),
          ),
      ]);
    } else if (tab == 'Jobs') {
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Btn('Post a job', icon: Icons.add, onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const PostJobSheet())),
        const SizedBox(height: 14),
        if (s.jobs.isEmpty) const SizedBox(height: 180, child: Empty(Icons.work_outline, 'You have not posted any jobs.')),
        for (final j in s.jobs)
          Column(children: [
            JobTile(j),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => s.removeJob(j),
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                label: Text('Remove  ·  ${apps.where((a) => a.job.id == j.id).length} applicants', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            ),
          ]),
      ]);
    } else {
      final total = apps.isEmpty ? 1 : apps.length;
      Widget bar(String l, int v) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 90, child: Text(l, style: const TextStyle(fontSize: 13))),
              Expanded(child: LinearProgressIndicator(value: v / total, minHeight: 8, color: context.fg, backgroundColor: context.linec, borderRadius: BorderRadius.circular(4))),
              SizedBox(width: 30, child: Text('$v', textAlign: TextAlign.right)),
            ]),
          );
      body = Box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Pipeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final st in ['Applied', 'Under review', 'Shortlisted', 'Interview', 'Offer', 'Rejected']) bar(st, n(st)),
          const Divider(),
          Text('Open jobs: ${s.jobs.length}   ·   Applicants: ${apps.length}', style: TextStyle(color: context.mutedc)),
        ]),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Heading('Talent Dashboard', 'Find, manage and hire the best talent.'), toolbarHeight: 70),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [stat('${apps.length}', 'Total Applicants'), const SizedBox(width: 8), stat('${n('Shortlisted')}', 'Shortlisted'), const SizedBox(width: 8), stat('${n('Interview')}', 'Interviews')]),
        Row(children: [for (final t in ['Candidates', 'Jobs', 'Analytics']) Expanded(child: Pill(t, selected: tab == t, onTap: () => setState(() => tab = t)))]),
        const SizedBox(height: 10),
        body,
      ]),
    );
  }
}
