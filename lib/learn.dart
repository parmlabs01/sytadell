import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';

const kCourseCats = ['Tech', 'Business', 'Design', 'Soft Skills'];

class LearnTab extends StatefulWidget {
  const LearnTab({super.key});
  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  String q = '', cat = 'All';
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final list = s.courses.where((c) => (cat == 'All' || c.category == cat) && '${c.title} ${c.description} ${c.category}'.toLowerCase().contains(q.toLowerCase())).toList();
    final mine = s.courses.where((c) => c.enrolled).toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        const Expanded(child: Heading('Learn & Grow', 'Build your skills and unlock new opportunities.')),
        IconButton(icon: const Icon(Icons.add), tooltip: 'Create a course', onPressed: () => push(context, const CreateCourseScreen())),
      ]),
      const SizedBox(height: 14),
      TextField(onChanged: (v) => setState(() => q = v), decoration: dec(context, 'Search courses, skills or topics', prefix: const Icon(Icons.search, size: 20))),
      const SizedBox(height: 10),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final c in ['All', ...kCourseCats]) Pill(c, selected: cat == c, onTap: () => setState(() => cat = c))])),
      if (mine.isNotEmpty) ...[
        const SizedBox(height: 10),
        const Text('Continue learning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...mine.map((c) => CourseCard(c)),
      ],
      const SizedBox(height: 10),
      const Text('Recommended for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      if (list.isEmpty) const SizedBox(height: 160, child: Empty(Icons.menu_book_outlined, 'No courses yet. Tap + to publish the first one.')),
      ...list.where((c) => !c.enrolled).map((c) => CourseCard(c)),
      const SizedBox(height: 14),
      Row(children: [
        const Expanded(child: Text('Popular communities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
        TextButton(onPressed: () => askForm(context, 'New community', ['Community name'], (v) => ifFilled(v[0], () => s.addCommunity(v[0]))), child: const Text('+ New')),
      ]),
      if (s.communities.isEmpty) SizedBox(height: 100, child: Empty(Icons.groups_outlined, 'No communities yet.')),
      for (final cm in s.communities)
        Box(
          child: Row(children: [
            const Icon(Icons.groups_2_outlined),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cm.name, style: const TextStyle(fontWeight: FontWeight.w600)), Text('${cm.members} members', style: TextStyle(color: context.mutedc, fontSize: 12))])),
            Pill(cm.joined ? 'Joined' : 'Join', selected: !cm.joined, onTap: () => s.toggleJoin(cm)),
          ]),
        ),
    ]);
  }
}

class CourseCard extends StatelessWidget {
  final Course c;
  const CourseCard(this.c, {super.key});
  @override
  Widget build(BuildContext context) => Box(
        onTap: () => push(context, CourseDetails(c)),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: context.fg.withOpacity(.08), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.menu_book_outlined)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Course  ·  ${c.level}  ·  ${c.lessons.length} lessons', style: TextStyle(color: context.mutedc, fontSize: 12)),
              if (c.enrolled) Padding(padding: const EdgeInsets.only(top: 6), child: LinearProgressIndicator(value: c.progress, minHeight: 4, color: context.fg, backgroundColor: context.linec)),
            ]),
          ),
          const Icon(Icons.chevron_right),
        ]),
      );
}

class CourseDetails extends StatelessWidget {
  final Course c;
  const CourseDetails(this.c, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final complete = c.progress >= 1;
    return Scaffold(
      appBar: AppBar(title: Text(c.category)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(c.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${c.level}  ·  by ${c.author}', style: TextStyle(color: context.mutedc)),
        const SizedBox(height: 12),
        Text(c.description, style: const TextStyle(height: 1.4)),
        const SizedBox(height: 16),
        if (c.enrolled) ...[
          Row(children: [Expanded(child: LinearProgressIndicator(value: c.progress, minHeight: 5, color: context.fg, backgroundColor: context.linec)), const SizedBox(width: 10), Text('${(c.progress * 100).round()}%')]),
          const SizedBox(height: 12),
        ],
        const Text('Lessons', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        for (var i = 0; i < c.lessons.length; i++)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: c.done.contains(i),
            title: Text('${i + 1}. ${c.lessons[i]}'),
            onChanged: (_) => s.toggleLesson(c, i),
          ),
        const SizedBox(height: 10),
        if (complete)
          Btn('Add certificate to my profile', icon: Icons.verified_outlined, onTap: () {
            final name = '${c.title} (sytadell course)';
            if (!s.certs.contains(name)) s.add(s.certs, name);
            snack(context, 'Added to your certifications');
          })
        else
          Btn(c.enrolled ? 'Leave course' : 'Enroll now', filled: !c.enrolled, onTap: () => s.toggleEnroll(c)),
      ]),
    );
  }
}

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});
  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final t = TextEditingController(), d = TextEditingController(), l = TextEditingController();
  String cat = 'Tech', level = 'Beginner';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create a course')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Field(t, 'Course title'),
          Field(d, 'Description', maxLines: 4),
          const Text('Category'),
          const SizedBox(height: 6),
          Wrap(children: [for (final c in kCourseCats) Pill(c, selected: cat == c, onTap: () => setState(() => cat = c))]),
          const SizedBox(height: 8),
          const Text('Level'),
          const SizedBox(height: 6),
          Wrap(children: [for (final c in ['Beginner', 'Intermediate', 'Advanced']) Pill(c, selected: level == c, onTap: () => setState(() => level = c))]),
          const SizedBox(height: 12),
          Field(l, 'Lessons (one per line)', maxLines: 6),
          Btn('Publish course', onTap: () {
            final lessons = splitList(l.text, '\n');
            if (t.text.trim().isEmpty || lessons.isEmpty) return snack(context, 'Add a title and at least one lesson');
            final s = S(context);
            s.addCourse(Course(DateTime.now().microsecondsSinceEpoch.toString(), t.text.trim(), cat, level, d.text.trim(), s.name ?? 'Me', lessons));
            Navigator.pop(context);
          }),
        ]),
      );
}
