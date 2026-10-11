import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets.dart';
import 'misc.dart';
import 'freelance.dart';
import 'profile.dart';

class _Slide {
  final String asset, title, desc, button;
  final double ratio;
  final IconData icon;
  final Widget Function() page;
  const _Slide(this.asset, this.title, this.desc, this.button, this.icon, this.page, {this.ratio = 1200 / 549});
}

final _slides = <_Slide>[
  _Slide('assets/banners/career_smarter.jpg', 'Your career, smarter.', 'Let AI find the right opportunities, match you with top companies and help you grow.', 'Try AI Assistant', Icons.auto_awesome,
      () => const AiAssistantScreen()),
  _Slide('assets/banners/ai_career.jpg', 'AI Career Assistant', 'Improve your CV, find skill gaps, practise interviews and explore career paths.', 'Open AI Assistant', Icons.smart_toy_outlined,
      () => const AiAssistantScreen()),
  _Slide('assets/banners/freelance.jpg', 'Freelance Marketplace', 'Find gigs, showcase your skills and work with clients worldwide.', 'Browse Gigs', Icons.laptop_mac,
      () => const FreelanceScreen()),
  _Slide('assets/banners/post_service.jpg', 'Showcase your skills. Get clients.', 'Create a professional service listing in minutes and reach clients worldwide.', 'Post Your Service Now', Icons.rocket_launch_outlined,
      () => const PostServiceScreen(), ratio: 1200 / 600),
  _Slide('assets/banners/build_cv.jpg', 'Create a CV that gets you noticed', 'Build an ATS-friendly CV with modern templates, custom designs and PDF download.', 'Build My CV', Icons.description_outlined,
      () => const CvBuilderScreen()),
];

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});
  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final _ctrl = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_ctrl.hasClients) return;
      _ctrl.animateToPage((_page + 1) % _slides.length, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final imgH = c.maxWidth / (1200 / 600); // tallest image; others are letterboxed to the same height
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(children: [
          SizedBox(
            height: imgH + 150,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _slides.length,
              onPageChanged: (i) {
                setState(() => _page = i);
                _start();
              },
              itemBuilder: (_, i) {
                final sl = _slides[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(color: context.cardc, borderRadius: BorderRadius.circular(20), border: Border.all(color: context.linec)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        height: imgH,
                        width: double.infinity,
                        child: ColoredBox(color: const Color(0xFF050B1A), child: Image.asset(sl.asset, fit: BoxFit.contain)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(sl.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(sl.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: context.mutedc)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: FilledButton.icon(
                              onPressed: () => push(context, sl.page()),
                              icon: Icon(sl.icon, size: 18),
                              label: Text(sl.button, style: const TextStyle(fontWeight: FontWeight.w600)),
                              style: FilledButton.styleFrom(backgroundColor: context.fg, foregroundColor: context.bgc, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                            ),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(color: i == _page ? context.fg : context.linec, borderRadius: BorderRadius.circular(4)),
              ),
          ]),
        ]),
      );
    });
  }
}
