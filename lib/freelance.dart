import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';
import 'misc.dart';

const kCategories = <String, List<String>>{
  'Web Development': ['Frontend', 'Backend', 'Full Stack', 'WordPress', 'E-commerce'],
  'Mobile Apps': ['Android', 'iOS', 'Flutter', 'React Native'],
  'Design & Creative': ['UI/UX', 'Logo & Branding', 'Illustration', 'Video & Motion'],
  'Writing & Translation': ['Copywriting', 'Content writing', 'Translation', 'Proofreading'],
  'Digital Marketing': ['SEO', 'Social media', 'Email marketing', 'Ads'],
  'Data & AI': ['Data analysis', 'Machine learning', 'Data visualization', 'Automation'],
};

const _catIcons = <String, IconData>{
  'Web Development': Icons.code,
  'Mobile Apps': Icons.smartphone,
  'Design & Creative': Icons.palette_outlined,
  'Writing & Translation': Icons.article_outlined,
  'Digital Marketing': Icons.campaign_outlined,
  'Data & AI': Icons.storage_outlined,
};

class FreelanceScreen extends StatefulWidget {
  const FreelanceScreen({super.key});
  @override
  State<FreelanceScreen> createState() => _FreelanceScreenState();
}

class _FreelanceScreenState extends State<FreelanceScreen> {
  String? cat;
  String sort = 'Newest', q = '';
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final list = s.services.where((v) => (cat == null || v.category == cat) && '${v.title} ${v.desc} ${v.skills.join(' ')}'.toLowerCase().contains(q.toLowerCase())).toList();
    if (sort == 'Highest Pay') list.sort((a, b) => b.price.compareTo(a.price));
    if (sort == 'Popular') list.sort((a, b) => (s.savedServices.contains(b.id) ? 1 : 0).compareTo(s.savedServices.contains(a.id) ? 1 : 0));
    if (sort == 'Newest') list.sort((a, b) => b.posted.compareTo(a.posted));
    Widget tile(IconData i, String t, String sub, VoidCallback f) => Expanded(
          child: GestureDetector(
            onTap: f,
            child: Column(children: [
              Icon(i, size: 26),
              const SizedBox(height: 6),
              Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5), textAlign: TextAlign.center),
              Text(sub, style: TextStyle(fontSize: 10.5, color: context.mutedc), textAlign: TextAlign.center),
            ]),
          ),
        );
    return Scaffold(
      appBar: AppBar(
        title: const Heading('Freelance Marketplace', 'Find gigs, showcase your skills, and work with clients.'),
        toolbarHeight: 70,
        actions: [IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => push(context, const NotificationsScreen()))],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Box(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('YOUR SKILLS. GLOBAL OPPORTUNITIES.', style: TextStyle(fontSize: 10.5, letterSpacing: 1.2, color: context.mutedc)),
            const SizedBox(height: 6),
            const Text('Turn Your Skills Into Income', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.1)),
            const SizedBox(height: 6),
            const Text('Get freelance gigs, build your reputation, and work with clients from around the world.'),
          ]),
        ),
        TextField(onChanged: (v) => setState(() => q = v), decoration: dec(context, 'Search gigs', prefix: const Icon(Icons.search, size: 20))),
        const SizedBox(height: 12),
        Box(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(children: [
            tile(Icons.search, 'Find Gigs', 'Explore', () => setState(() => cat = null)),
            tile(Icons.add_circle_outline, 'Post a Service', 'Offer skills', () => push(context, const PostServiceScreen())),
            tile(Icons.send_outlined, 'My Proposals', 'Track bids', () => push(context, const ProposalsScreen())),
            tile(Icons.account_balance_wallet_outlined, 'Wallet', 'Earnings', () => push(context, const WalletScreen())),
            tile(Icons.person_outline, 'My Services', 'View & edit', () => push(context, const MyServicesScreen())),
          ]),
        ),
        const SizedBox(height: 6),
        const Text('Popular Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [for (final c in kCategories.keys) Pill(c, icon: _catIcons[c], selected: cat == c, onTap: () => setState(() => cat = cat == c ? null : c))]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          const Expanded(child: Text('Featured Gigs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          for (final x in ['Popular', 'Newest', 'Highest Pay']) Pill(x, small: true, selected: sort == x, onTap: () => setState(() => sort = x)),
        ]),
        const SizedBox(height: 8),
        if (list.isEmpty) const SizedBox(height: 180, child: Empty(Icons.laptop_mac, 'No gigs yet. Tap Post a Service to list yours.')),
        for (final v in list) ServiceCard(v),
      ]),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service v;
  const ServiceCard(this.v, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final fav = s.savedServices.contains(v.id);
    return Box(
      onTap: () => push(context, ServiceDetails(v)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(v.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5))),
          GestureDetector(onTap: () => s.toggleSaveService(v), child: Icon(fav ? Icons.favorite : Icons.favorite_border, size: 21)),
        ]),
        const SizedBox(height: 4),
        Text(v.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.mutedc, fontSize: 12.5)),
        const SizedBox(height: 6),
        Wrap(children: v.skills.take(4).map((e) => Pill(e, small: true)).toList()),
        Row(children: [
          CircleAvatar(radius: 12, backgroundColor: context.linec, child: Text(v.seller[0].toUpperCase(), style: const TextStyle(fontSize: 11))),
          const SizedBox(width: 8),
          Expanded(child: Text(v.seller, style: const TextStyle(fontSize: 13))),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(naira(v.price), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            Text('Starting price', style: TextStyle(fontSize: 10.5, color: context.mutedc)),
          ]),
        ]),
        const SizedBox(height: 8),
        Btn(v.mine ? 'View my service' : 'Send Proposal', onTap: () => push(context, ServiceDetails(v))),
      ]),
    );
  }
}

class ServiceDetails extends StatefulWidget {
  final Service v;
  const ServiceDetails(this.v, {super.key});
  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  String tab = 'Overview';
  int pkg = 0;
  @override
  Widget build(BuildContext context) {
    final s = S(context);
    final v = widget.v;
    final fav = s.savedServices.contains(v.id);
    final pkgs = v.packages.isEmpty ? [Package('Basic', v.price, v.delivery, [])] : v.packages;
    final sel = pkgs[pkg.clamp(0, pkgs.length - 1)];
    void order() {
      if (v.mine) return snack(context, 'This is your own service');
      askForm(context, 'Hire ${v.seller} · ${sel.name} (${naira(sel.price)})', ['Message to ${v.seller}'], (m) {
        s.sendProposal(v, '[${sel.name}] ${m[0]}');
        snack(context, 'Request sent');
      }, multiline: {0}, saveLabel: 'Send request');
    }

    Widget content;
    switch (tab) {
      case 'Packages':
        content = Column(children: [
          for (final (i, p) in pkgs.indexed)
            Box(
              onTap: () => setState(() => pkg = i),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  Icon(pkg == i ? Icons.radio_button_checked : Icons.radio_button_off, size: 20),
                ]),
                Text('${naira(p.price)}   ·   ${p.delivery} delivery', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                for (final ft in p.features) Text('✓  $ft', style: const TextStyle(fontSize: 13)),
              ]),
            ),
        ]);
        break;
      case 'Reviews':
        content = const SizedBox(height: 160, child: Empty(Icons.star_border, 'No reviews yet.'));
        break;
      case 'Portfolio':
        content = const SizedBox(height: 160, child: Empty(Icons.image_outlined, 'No portfolio items yet.'));
        break;
      case 'FAQs':
        content = v.faqs.isEmpty
            ? const SizedBox(height: 160, child: Empty(Icons.help_outline, 'The seller has not added FAQs.'))
            : Column(children: [for (final q in v.faqs) Box(child: Row(children: [const Icon(Icons.help_outline, size: 18), const SizedBox(width: 10), Expanded(child: Text(q))]))]);
        break;
      default:
        content = Column(children: [
          Section(Icons.description_outlined, 'Description', child: Align(alignment: Alignment.centerLeft, child: Text(v.desc, style: const TextStyle(height: 1.4)))),
          if (v.skills.isNotEmpty) Section(Icons.sell_outlined, 'Skills', child: Align(alignment: Alignment.centerLeft, child: Wrap(children: v.skills.map((e) => Pill(e)).toList()))),
          Box(
              child: Row(children: [
            CircleAvatar(radius: 24, backgroundColor: context.linec, child: Text(v.seller[0].toUpperCase(), style: const TextStyle(fontSize: 20))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(v.seller, style: const TextStyle(fontWeight: FontWeight.w700)), Text('Posted ${ago(v.posted)}', style: TextStyle(color: context.mutedc, fontSize: 12))])),
            Pill('Message', onTap: v.mine ? null : () => push(context, ChatScreen(s.startChat(v.seller)))),
          ])),
        ]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Heading('Service Details', 'Review, message, and start your project.'),
        toolbarHeight: 70,
        actions: [IconButton(icon: Icon(fav ? Icons.bookmark : Icons.bookmark_border), onPressed: () => s.toggleSaveService(v))],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(v.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: 4),
        Text('${v.category}  ›  ${v.sub}', style: TextStyle(color: context.mutedc, fontSize: 12.5)),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final t in ['Overview', 'Packages', 'Reviews', 'Portfolio', 'FAQs']) Pill(t, selected: tab == t, onTap: () => setState(() => tab = t))])),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 8),
        Text('Extras: ${v.revisions >= 99 ? 'unlimited' : v.revisions} revision(s)${v.custom ? ' · custom offers welcome' : ''}${v.discount ? ' · discount available' : ''}${v.featured ? ' · featured' : ''}', style: TextStyle(color: context.mutedc, fontSize: 12)),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Btn('Message', filled: false, icon: Icons.chat_bubble_outline, onTap: v.mine ? null : () => push(context, ChatScreen(s.startChat(v.seller))))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: Btn('Proceed · ${naira(sel.price)}', icon: Icons.send, onTap: order)),
          ]),
        ),
      ),
    );
  }
}

class PostServiceScreen extends StatefulWidget {
  const PostServiceScreen({super.key});
  @override
  State<PostServiceScreen> createState() => _PostServiceScreenState();
}

class _PostServiceScreenState extends State<PostServiceScreen> {
  final title = TextEditingController(), desc = TextEditingController(), skill = TextEditingController(), price = TextEditingController();
  final basicF = TextEditingController(), stdP = TextEditingController(), stdF = TextEditingController(), premP = TextEditingController(), premF = TextEditingController(), faqs = TextEditingController();
  String? stdD, premD;
  String? cat, sub, delivery, revisions;
  final List<String> skills = [];
  int images = 0;
  bool featured = false, discount = false, custom = false;

  Widget block(IconData i, String t, String sub, Widget child) => Box(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(i, size: 20), const SizedBox(width: 10), Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))]),
        Padding(padding: const EdgeInsets.only(top: 2, bottom: 10), child: Text(sub, style: TextStyle(color: context.mutedc, fontSize: 12))),
        child,
      ]));

  void addSkill() {
    final t = skill.text.trim();
    if (t.isEmpty || skills.contains(t)) return;
    setState(() {
      skills.add(t);
      skill.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: const Heading('Post a Service', 'Showcase your skills and get hired by clients worldwide.'), toolbarHeight: 70),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        block(Icons.article_outlined, 'Service Title', 'Write a clear and catchy title for your service.',
            Field(title, '', hint: 'e.g. Build a modern website with React and Node.js', maxLength: 80)),
        block(
            Icons.grid_view,
            'Category & Subcategory',
            'Choose the right category so clients can find your service.',
            Row(children: [
              Expanded(child: Select(value: cat, hint: 'Select a category', items: kCategories.keys.toList(), onChanged: (v) => setState(() {cat = v; sub = null;}))),
              const SizedBox(width: 8),
              Expanded(child: Select(value: sub, hint: 'Subcategory', items: cat == null ? [] : kCategories[cat]!, onChanged: (v) => setState(() => sub = v))),
            ])),
        block(Icons.chat_bubble_outline, 'Description', 'Explain what you offer and what the client will get.', Field(desc, '', hint: 'Describe your service in detail...', maxLines: 5, maxLength: 2000)),
        block(
            Icons.sell_outlined,
            'Skills & Tags',
            'Add relevant skills to improve your visibility.',
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: TextField(controller: skill, onSubmitted: (_) => addSkill(), decoration: dec(context, 'e.g. React, Python, UI/UX, Figma...'))),
                const SizedBox(width: 8),
                Pill('+ Add Skill', onTap: addSkill),
              ]),
              const SizedBox(height: 8),
              Wrap(children: [for (final k in skills) Pill('$k  ✕', onTap: () => setState(() => skills.remove(k)))]),
            ])),
        block(
            Icons.attach_money,
            'Pricing & Delivery',
            'Set your price and how long it will take to deliver.',
            Column(children: [
              Field(price, 'Price (₦)', hint: 'e.g. 50000', keyboard: TextInputType.number),
              Row(children: [
                Expanded(child: Select(value: delivery, hint: 'Delivery time', items: const ['1 day', '3 days', '5 days', '7 days', '14 days', '30 days'], onChanged: (v) => setState(() => delivery = v))),
                const SizedBox(width: 8),
                Expanded(child: Select(value: revisions, hint: 'Revisions', items: const ['1', '2', '3', '5', 'Unlimited'], onChanged: (v) => setState(() => revisions = v))),
              ]),
            ])),
        block(
            Icons.inventory_2_outlined,
            'Packages',
            'Basic uses your price above. Standard and Premium are optional.',
            Column(children: [
              Field(basicF, 'Basic features (one per line)', maxLines: 3),
              Field(stdP, 'Standard price (₦)', keyboard: TextInputType.number),
              Select(value: stdD, hint: 'Standard delivery', items: const ['1 day', '3 days', '5 days', '7 days', '14 days', '30 days'], onChanged: (v) => setState(() => stdD = v)),
              const SizedBox(height: 10),
              Field(stdF, 'Standard features (one per line)', maxLines: 3),
              Field(premP, 'Premium price (₦)', keyboard: TextInputType.number),
              Select(value: premD, hint: 'Premium delivery', items: const ['1 day', '3 days', '5 days', '7 days', '14 days', '30 days'], onChanged: (v) => setState(() => premD = v)),
              const SizedBox(height: 10),
              Field(premF, 'Premium features (one per line)', maxLines: 3),
            ])),
        block(Icons.help_outline, 'FAQs', 'One question and answer per line (optional).', Field(faqs, '', maxLines: 3)),
        block(
            Icons.image_outlined,
            'Service Images / Portfolio',
            'Add images or samples of your work (optional).',
            Btn(images == 0 ? 'Tap to upload (JPG, PNG, max 10MB)' : '$images image(s) selected · add more', filled: false, icon: Icons.cloud_upload_outlined, onTap: () async {
              final r = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
              if (r != null) setState(() => images += r.files.length);
            })),
        block(
            Icons.settings_outlined,
            'Additional Options',
            'Make your service stand out.',
            Column(children: [
              CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, value: featured, onChanged: (v) => setState(() => featured = v ?? false), title: const Text('Featured Service'), subtitle: const Text('Get higher visibility')),
              CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, value: discount, onChanged: (v) => setState(() => discount = v ?? false), title: const Text('Offer a Discount'), subtitle: const Text('Attract more clients')),
              CheckboxListTile(dense: true, contentPadding: EdgeInsets.zero, value: custom, onChanged: (v) => setState(() => custom = v ?? false), title: const Text('Allow Custom Offers'), subtitle: const Text('Let clients negotiate')),
            ])),
        Btn('Post Service', icon: Icons.send, onTap: () {
          final p = int.tryParse(price.text.trim());
          if (title.text.trim().isEmpty || cat == null || sub == null || desc.text.trim().isEmpty) return snack(context, 'Add a title, category, subcategory and description');
          if (p == null || p <= 0 || delivery == null) return snack(context, 'Enter a valid price and delivery time');
          s.addService(Service(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title.text.trim(),
            category: cat!,
            sub: sub!,
            desc: desc.text.trim(),
            seller: s.name ?? 'Me',
            skills: skills,
            price: p,
            delivery: delivery!,
            revisions: revisions == 'Unlimited' ? 99 : int.tryParse(revisions ?? '1') ?? 1,
            featured: featured,
            discount: discount,
            custom: custom,
            mine: true,
            posted: DateTime.now(),
            packages: [
              Package('Basic', p, delivery!, splitList(basicF.text, '\n')),
              if (int.tryParse(stdP.text.trim()) != null && stdD != null) Package('Standard', int.parse(stdP.text.trim()), stdD!, splitList(stdF.text, '\n')),
              if (int.tryParse(premP.text.trim()) != null && premD != null) Package('Premium', int.parse(premP.text.trim()), premD!, splitList(premF.text, '\n')),
            ],
            faqs: splitList(faqs.text, '\n'),
          ));
          Navigator.pop(context);
          snack(context, 'Service posted');
        }),
      ]),
    );
  }
}

class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final mine = S(context).services.where((e) => e.mine).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Services'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => push(context, const PostServiceScreen()))]),
      body: mine.isEmpty ? const Empty(Icons.person_outline, 'You have not posted any services.') : ListView(padding: const EdgeInsets.all(20), children: mine.map((e) => ServiceCard(e)).toList()),
    );
  }
}

class ProposalsScreen extends StatelessWidget {
  const ProposalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = S(context).proposals;
    return Scaffold(
      appBar: AppBar(title: const Text('My Proposals')),
      body: l.isEmpty
          ? const Empty(Icons.send_outlined, 'No proposals yet.')
          : ListView(padding: const EdgeInsets.all(20), children: [
              for (final p in l)
                Box(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.service.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${p.service.seller}  ·  ${naira(p.service.price)}  ·  ${ago(p.date)}', style: TextStyle(color: context.mutedc, fontSize: 12)),
                  if (p.message.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(p.message)),
                ])),
            ]),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Wallet')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Box(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Available balance', style: TextStyle(color: context.mutedc)),
                const SizedBox(height: 4),
                Text(naira(0), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
              ])),
          const SizedBox(height: 8),
          const SizedBox(height: 220, child: Empty(Icons.account_balance_wallet_outlined, 'No transactions yet. Earnings and payouts appear here once payments are connected.')),
        ]),
      );
}
