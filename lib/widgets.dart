import 'package:flutter/material.dart';
import 'state.dart';

extension Tx on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get fg => isDark ? Colors.white : Colors.black;
  Color get bgc => isDark ? Colors.black : Colors.white;
  Color get cardc => isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5);
  Color get linec => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD9D9D9);
  Color get mutedc => isDark ? const Color(0xFF8A8A8A) : const Color(0xFF6B6B6B);
  Color get fieldc => isDark ? const Color(0xFF111111) : Colors.white;
}

AppState S(BuildContext c) => Scope.of(c);

void push(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

String ago(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hours ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${(diff.inDays / 7).floor()} weeks ago';
}

String naira(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '₦$b';
}

List<String> splitList(String s, Pattern p) => s.split(p).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

InputDecoration dec(BuildContext c, String hint, {Widget? prefix, Widget? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: c.mutedc),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: c.fieldc,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.linec)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.fg.withOpacity(.6))),
    );

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 56});
  @override
  Widget build(BuildContext context) => Icon(Icons.layers_rounded, size: size, color: context.fg);
}

class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final IconData? icon;
  const Btn(this.label, {super.key, this.onTap, this.filled = true, this.icon});
  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));
    final child = Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
      Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
    ]);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(backgroundColor: context.fg, foregroundColor: context.bgc, shape: shape),
              child: child)
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(foregroundColor: context.fg, side: BorderSide(color: context.linec), shape: shape),
              child: child),
    );
  }
}

class Field extends StatelessWidget {
  final TextEditingController c;
  final String label, hint;
  final bool obscure;
  final int maxLines;
  final int? maxLength;
  final IconData? icon;
  final TextInputType? keyboard;
  final ValueChanged<String>? onChanged;
  const Field(this.c, this.label,
      {super.key, this.hint = '', this.obscure = false, this.maxLines = 1, this.maxLength, this.icon, this.keyboard, this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label.isNotEmpty) ...[
            Text(label, style: TextStyle(fontSize: 13, color: context.mutedc)),
            const SizedBox(height: 6),
          ],
          TextField(
            controller: c,
            obscureText: obscure,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboard,
            onChanged: onChanged,
            decoration: dec(context, hint, prefix: icon == null ? null : Icon(icon, size: 20, color: context.mutedc)),
          ),
        ]),
      );
}

class Box extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const Box({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: context.cardc,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: context.linec)),
          child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool small;
  const Pill(this.text, {super.key, this.selected = false, this.onTap, this.icon, this.small = false});
  @override
  Widget build(BuildContext context) {
    final col = selected ? context.bgc : context.fg.withOpacity(.85);
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: small ? 10 : 14, vertical: small ? 5 : 8),
          decoration: BoxDecoration(
            color: selected ? context.fg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? context.fg : context.linec),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 15, color: col), const SizedBox(width: 6)],
            Text(text, style: TextStyle(fontSize: small ? 11 : 12.5, color: col)),
          ]),
        ),
      ),
    );
  }
}

class Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const Empty(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 40, color: context.mutedc),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: TextStyle(color: context.mutedc)),
          ]),
        ),
      );
}

class Ring extends StatelessWidget {
  final double value;
  final String label;
  final double size;
  const Ring(this.value, this.label, {super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(child: CircularProgressIndicator(value: value, strokeWidth: 4, backgroundColor: context.linec, color: context.fg)),
          Text(label, style: TextStyle(fontSize: size / 4.2, fontWeight: FontWeight.w600)),
        ]),
      );
}

class Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;
  const Section(this.icon, this.title, {super.key, required this.child, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: const TextStyle(fontSize: 13))),
          ]),
          const SizedBox(height: 10),
          child,
        ]),
      );
}

class Heading extends StatelessWidget {
  final String title, sub;
  const Heading(this.title, this.sub, {super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        if (sub.isNotEmpty) Text(sub, style: TextStyle(color: context.mutedc, fontSize: 13)),
      ]);
}

class Select extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const Select({super.key, required this.value, required this.hint, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: context.linec), borderRadius: BorderRadius.circular(22)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint, style: TextStyle(fontSize: 13, color: context.mutedc)),
            dropdownColor: context.cardc,
            style: TextStyle(fontSize: 13, color: context.fg),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

/// Bottom-sheet form for adding / editing simple text values.
void ifFilled(String v, VoidCallback f) {
  if (v.isNotEmpty) f();
}

void askForm(BuildContext context, String title, List<String> labels, void Function(List<String>) onSave,
    {List<String>? initial, Set<int> multiline = const {}, String saveLabel = 'Save'}) {
  final ctrls = [for (var i = 0; i < labels.length; i++) TextEditingController(text: initial != null && i < initial.length ? initial[i] : '')];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          for (var i = 0; i < labels.length; i++) Field(ctrls[i], labels[i], maxLines: multiline.contains(i) ? 4 : 1),
          Btn(saveLabel, onTap: () {
            onSave(ctrls.map((e) => e.text.trim()).toList());
            Navigator.pop(ctx);
          }),
        ]),
      ),
    ),
  );
}

void infoSheet(BuildContext context, String title, List<String> lines) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .7),
          child: ListView(shrinkWrap: true, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...lines.map((l) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(l, style: const TextStyle(height: 1.4)))),
          ]),
        ),
      ),
    ),
  );
}
