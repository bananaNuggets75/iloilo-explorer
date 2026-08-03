import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SuroyIloilo visual system — the Dayon app look: ink, teal and signboard
/// yellow on a cool paper ground, with a bold condensed display face. This
/// replaced an earlier cream/serif "editorial" theme that read as a blog,
/// not an app.
class AppColors {
  static const cream = Color(0xFFF4F6F5); // page background (cool paper)
  static const surface = Color(0xFFFFFFFF); // cards
  static const rust = Color(0xFF0D8E5F); // primary / accents (teal)
  static const rustDark = Color(0xFF096B47);
  static const ink = Color(0xFF16232A); // headings / dark text
  static const muted = Color(0xFF5B6B70); // secondary text
  static const chip = Color(0xFFE3EFEA); // soft chip background
  static const chipInk = Color(0xFF115C43);
  static const priceBg = Color(0xFFFCEBBE); // signboard-yellow price pill
  static const priceInk = Color(0xFF7A5A0A);
  static const line = Color(0xFFE1E7E6); // hairline dividers
  static const star = Color(0xFFE0A32E);
  static const signboard = Color(0xFFF6BE3F); // signage yellow accent
}

class AppTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rust,
        primary: AppColors.rust,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.cream,
    );

    const display = GoogleFonts.anton; // bold condensed — the app's voice
    const body = GoogleFonts.archivo; // clean grotesque for body/UI

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: display(color: AppColors.ink, height: 1.02),
        headlineMedium: display(color: AppColors.ink, height: 1.05),
        headlineSmall: display(color: AppColors.ink, height: 1.08),
        titleLarge: display(color: AppColors.ink, height: 1.1),
        titleMedium: body(
            fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 16),
        bodyLarge: body(color: AppColors.ink, height: 1.4),
        bodyMedium: body(color: AppColors.muted, height: 1.4),
        bodySmall: body(color: AppColors.muted),
        labelLarge: body(fontWeight: FontWeight.w700),
      ),
      dividerColor: AppColors.line,
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }
}

/// Rounded card surface used across tabs.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F1A16),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small rounded label pill (mode, fare, time, category).
class Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color bg;
  final Color fg;
  const Pill(this.text,
      {super.key,
      this.icon,
      this.bg = AppColors.chip,
      this.fg = AppColors.chipInk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
          ],
          Text(text,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Dayon UI-kit tokens (from the v0.1 design kit) — used by the landing
/// screen and the jeepney signboard plates. The main AppColors palette above
/// now draws from the same family, so this exists mainly for the pure-ink
/// landing screen background and the plate widget below.
class DayonColors {
  static const ink = Color(0xFF1A2B2E);
  static const teal = Color(0xFF0D8E5F);
  static const signboard = Color(0xFFF6BE3F);
  static const red = Color(0xFFC93A25);
  static const paper = Color(0xFFFBFAF6);
  static const water = Color(0xFFBFD9DB);
}

/// Extracts the signboard text from a route mode label, e.g.
/// "Jeepney · Molo / Villa jeep" -> "Molo / Villa jeep".
String signboardOf(String mode) =>
    mode.contains('·') ? mode.split('·').last.trim() : mode;

/// The kit's signature element: a jeepney signboard plate. Used wherever a
/// ride instruction names the jeep to look for.
class JeepneyPlate extends StatelessWidget {
  final String text;
  final double fontSize;
  const JeepneyPlate(this.text, {super.key, this.fontSize = 13});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DayonColors.signboard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DayonColors.ink, width: 1.5),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.anton(
          fontSize: fontSize,
          color: DayonColors.ink,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Section eyebrow + title used at the top of each tab.
class SectionIntro extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const SectionIntro(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(),
            style: GoogleFonts.archivo(
                color: AppColors.rust,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontSize: 12)),
        const SizedBox(height: 10),
        Text(title, style: t.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: 10),
        Text(subtitle, style: t.bodyMedium?.copyWith(fontSize: 15)),
      ],
    );
  }
}
