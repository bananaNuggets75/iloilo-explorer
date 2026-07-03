import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/community_repository.dart';
import '../models.dart';
import '../theme.dart';

/// Bottom-sheet form to share an experience: nickname, topic, story and an
/// optional photo. Anonymous — no account needed. Returns the created post so
/// the feed can show it immediately.
Future<CommunityPost?> showShareExperienceSheet(
    BuildContext context, CommunityRepository repo) {
  return showModalBottomSheet<CommunityPost>(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ShareSheet(repo: repo),
  );
}

class _ShareSheet extends StatefulWidget {
  final CommunityRepository repo;
  const _ShareSheet({required this.repo});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _name = TextEditingController();
  final _from = TextEditingController();
  final _body = TextEditingController();
  String _topic = 'Experience';
  Uint8List? _imageBytes;
  String _imageExt = 'jpg';
  bool _submitting = false;
  String? _error;

  static const _topics = [
    'Experience',
    'Getting around',
    'Food',
    'Places',
    'Events',
    'Tips',
  ];

  @override
  void initState() {
    super.initState();
    widget.repo.savedNickname().then((n) {
      if (mounted && n.isNotEmpty) _name.text = n;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _from.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();
    setState(() {
      _imageBytes = bytes;
      _imageExt = (ext == 'png' || ext == 'webp') ? ext : 'jpg';
    });
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final body = _body.text.trim();
    if (name.isEmpty || body.isEmpty) {
      setState(() => _error = 'Please add your name and your story.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    await widget.repo.saveNickname(name);
    final post = await widget.repo.submitPost(
      author: name,
      from: _from.text.trim().isEmpty ? '' : 'from ${_from.text.trim()}',
      topic: _topic,
      body: body,
      imageBytes: _imageBytes,
      imageExtension: _imageExt,
    );
    if (!mounted) return;
    if (post == null) {
      setState(() {
        _submitting = false;
        _error = 'Could not post right now — please try again.';
      });
      return;
    }
    Navigator.of(context).pop(post);
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rust, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Share your experience',
                style: t.headlineSmall?.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text('No account needed — just your name and your story.',
                style: t.bodyMedium),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              maxLength: 40,
              decoration: _dec('Your name or nickname'),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _from,
              maxLength: 40,
              decoration: _dec('Where are you from? (optional)'),
            ),
            const SizedBox(height: 14),
            Text('Topic', style: t.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final topic in _topics)
                  ChoiceChip(
                    label: Text(topic),
                    selected: _topic == topic,
                    onSelected: (_) => setState(() => _topic = topic),
                    selectedColor: AppColors.rust,
                    labelStyle: TextStyle(
                      color: _topic == topic ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.line),
                    showCheckmark: false,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _body,
              maxLines: 5,
              maxLength: 1000,
              decoration: _dec(
                  'Your story — a tip, a hidden find, how the trip went...'),
            ),
            const SizedBox(height: 8),
            if (_imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(_imageBytes!,
                    height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(
                      _imageBytes == null ? 'Add a photo' : 'Change photo'),
                ),
                if (_imageBytes != null)
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _imageBytes = null),
                    child: const Text('Remove',
                        style: TextStyle(color: AppColors.rust)),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.rust, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.rust,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, size: 18),
              label: Text(_submitting ? 'Posting...' : 'Post experience'),
            ),
          ],
        ),
      ),
    );
  }
}
