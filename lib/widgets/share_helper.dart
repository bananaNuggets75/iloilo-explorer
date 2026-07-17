import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the platform share sheet; falls back to copying the text to the
/// clipboard (desktop browsers often have no native share sheet).
Future<void> shareText(BuildContext context, String text) async {
  try {
    final result = await Share.share(text);
    if (result.status == ShareResultStatus.unavailable) {
      throw Exception('share unavailable');
    }
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard — paste anywhere.')),
      );
    }
  }
}
