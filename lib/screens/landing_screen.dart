import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../theme.dart';

/// First-launch landing — the "Dayon!" welcome moment from the UI kit.
/// Big pitch, then straight into either the trip planner or the app.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const seenKey = 'suroy_seen_landing';

  Future<void> _enter(BuildContext context, int tabIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(seenKey, true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AppShell(initialIndex: tabIndex)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = GoogleFonts.anton(
      color: Colors.white,
      fontSize: 54,
      height: 1.0,
      letterSpacing: 0.5,
    );
    final body = GoogleFonts.archivo(
      color: Colors.white70,
      fontSize: 15,
      height: 1.5,
    );

    return Scaffold(
      backgroundColor: DayonColors.ink,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 18, 26, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const JeepneyPlate('Dayon!'),
                            const SizedBox(width: 10),
                            Text('"come in · welcome"',
                                style: body.copyWith(fontSize: 12)),
                          ]),
                          const Spacer(),
                          Text('RIDE LIKE\nA LOCAL.\nSEE IT ALL.',
                              style: display),
                          const SizedBox(height: 18),
                          Text(
                            'Jeepney routes, exact fares, and an optimized day plan '
                            'for Iloilo — plus the spots only locals know.',
                            style: body,
                          ),
                          const SizedBox(height: 26),
                          _bullet('Point-to-point jeepney directions', body),
                          _bullet('One-tap optimized day plans', body),
                          _bullet('Local gems from Ilonggos', body),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => _enter(context, 4),
                              style: FilledButton.styleFrom(
                                backgroundColor: DayonColors.signboard,
                                foregroundColor: DayonColors.ink,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text('Plan my day',
                                  style: GoogleFonts.archivo(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _enter(context, 0),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white38),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text('Explore Iloilo',
                                  style: GoogleFonts.archivo(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text('SuroyIloilo · pilot city: Iloilo',
                                style: body.copyWith(
                                    fontSize: 11, color: Colors.white38)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text, TextStyle body) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          const Icon(Icons.check_circle, size: 18, color: DayonColors.teal),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: body.copyWith(color: Colors.white))),
        ]),
      );
}
