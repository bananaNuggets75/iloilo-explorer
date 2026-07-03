import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/content_scope.dart';
import '../data/community_repository.dart';
import '../models.dart';
import '../widgets/share_experience_sheet.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  final _repo = CommunityRepository();
  List<CommunityPost> _posts = const [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await _repo.fetchPosts();
    if (mounted) setState(() => _posts = posts);
  }

  Future<void> _share() async {
    final created = await showShareExperienceSheet(context, _repo);
    if (created != null && mounted) {
      setState(() => _posts = [created, ..._posts]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salamat! Your experience is live.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final content = ContentScope.of(context);
    final events = content.events;
    final tips = content.tips;
    return RefreshIndicator(
      color: AppColors.rust,
      onRefresh: _loadPosts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
        children: [
          const SectionIntro(
            eyebrow: 'Community',
            title: 'Tips from travelers & highlighted events',
            subtitle:
                "Advice from people who've been, plus what's happening around "
                'the city.',
          ),
          const SizedBox(height: 18),
          _ShareBanner(onShare: _share, enabled: _repo.canPost),
          const SizedBox(height: 22),
          if (_posts.isNotEmpty) ...[
            Row(children: [
              const Icon(Icons.people, color: AppColors.rust, size: 20),
              const SizedBox(width: 8),
              Text('Traveler experiences',
                  style: t.headlineSmall?.copyWith(fontSize: 20)),
            ]),
            const SizedBox(height: 12),
            for (final post in _posts) ...[
              _PostCard(post: post, repo: _repo),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
          ],
          Row(children: [
            const Icon(Icons.celebration, color: AppColors.rust, size: 20),
            const SizedBox(width: 8),
            Text('Highlighted events',
                style: t.headlineSmall?.copyWith(fontSize: 20)),
          ]),
          const SizedBox(height: 12),
          for (final e in events) ...[
            _EventCard(event: e),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.forum, color: AppColors.rust, size: 20),
            const SizedBox(width: 8),
            Text('Traveler tips',
                style: t.headlineSmall?.copyWith(fontSize: 20)),
          ]),
          const SizedBox(height: 12),
          for (final tip in tips) ...[
            _TipCard(tip: tip),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Invitation card at the top of the tab — the community hook.
class _ShareBanner extends StatelessWidget {
  final VoidCallback onShare;
  final bool enabled;
  const _ShareBanner({required this.onShare, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.rust,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Been around Iloilo?',
              style: t.headlineSmall
                  ?.copyWith(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            enabled
                ? 'Share a tip or a photo — help the next traveler. No '
                    'account needed.'
                : 'Sharing needs an internet connection — try again once '
                    'you are online.',
            style: t.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: enabled ? onShare : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Share your experience'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final CommunityPost post;
  final CommunityRepository repo;
  const _PostCard({required this.post, required this.repo});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _helpful = widget.post.helpful;
  bool _hearted = false;

  @override
  void initState() {
    super.initState();
    widget.repo.hasHearted(widget.post.id).then((v) {
      if (mounted && v) setState(() => _hearted = true);
    });
  }

  Future<void> _heart() async {
    if (_hearted) return;
    final counted = await widget.repo.markHelpful(widget.post.id);
    if (counted && mounted) {
      setState(() {
        _hearted = true;
        _helpful += 1;
      });
    }
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final post = widget.post;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.chip,
              child: Text(
                post.author.isEmpty ? '?' : post.author.characters.first,
                style: const TextStyle(
                    color: AppColors.chipInk, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.author, style: t.titleMedium),
                  Text(
                    [
                      if (post.from.isNotEmpty) post.from,
                      _timeAgo(post.createdAt),
                    ].join(' · '),
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            if (post.topic.isNotEmpty) Pill(post.topic),
          ]),
          const SizedBox(height: 12),
          Text(post.body, style: t.bodyLarge),
          if (post.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                loadingBuilder: (context, child, progress) =>
                    progress == null
                        ? child
                        : Container(
                            height: 200,
                            color: AppColors.chip,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.rust, strokeWidth: 2),
                            ),
                          ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          InkWell(
            onTap: _heart,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hearted ? Icons.favorite : Icons.favorite_border,
                    size: 17,
                    color: AppColors.rust,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _helpful == 0
                        ? 'Helpful?'
                        : '$_helpful found this helpful',
                    style: t.bodySmall?.copyWith(color: AppColors.rust),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(event.name,
                  style: t.headlineSmall?.copyWith(fontSize: 20)),
            ),
            Pill(event.category, bg: AppColors.chip, fg: AppColors.rust),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.event_note, size: 15, color: AppColors.muted),
            const SizedBox(width: 4),
            Flexible(child: Text('${event.schedule} · ', style: t.bodySmall)),
            const Icon(Icons.place, size: 15, color: AppColors.muted),
            Flexible(child: Text(event.location, style: t.bodySmall)),
          ]),
          const SizedBox(height: 10),
          Text(event.description, style: t.bodyLarge),
          const SizedBox(height: 10),
          Text('Organized by ${event.organizer}', style: t.bodySmall),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final TravelerTip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.chip,
              child: Text(tip.author.characters.first,
                  style: const TextStyle(
                      color: AppColors.chipInk, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tip.author, style: t.titleMedium),
                  Text(tip.from, style: t.bodySmall),
                ],
              ),
            ),
            Pill(tip.topic),
          ]),
          const SizedBox(height: 12),
          Text('"${tip.text}"',
              style: t.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.favorite, size: 15, color: AppColors.rust),
            const SizedBox(width: 6),
            Text('${tip.helpful} found this helpful',
                style: t.bodySmall?.copyWith(color: AppColors.rust)),
          ]),
        ],
      ),
    );
  }
}
