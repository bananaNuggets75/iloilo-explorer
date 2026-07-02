import 'package:flutter/material.dart';
import 'content_repository.dart';

export 'content_repository.dart' show AppContent;

/// Provides [AppContent] to the widget tree. Starts with bundled seed data so
/// the UI renders instantly and offline, then refreshes from Supabase in the
/// background and rebuilds when live data arrives.
class ContentScope extends StatefulWidget {
  final Widget child;
  const ContentScope({super.key, required this.child});

  static AppContent of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ContentInherited>();
    assert(scope != null, 'ContentScope is missing from the widget tree');
    return scope!.content;
  }

  @override
  State<ContentScope> createState() => _ContentScopeState();
}

class _ContentScopeState extends State<ContentScope> {
  final _repo = ContentRepository();
  AppContent _content = AppContent.seed();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final loaded = await _repo.loadAll();
    if (mounted) setState(() => _content = loaded);
  }

  @override
  Widget build(BuildContext context) {
    return _ContentInherited(content: _content, child: widget.child);
  }
}

class _ContentInherited extends InheritedWidget {
  final AppContent content;
  const _ContentInherited({required this.content, required super.child});

  @override
  bool updateShouldNotify(_ContentInherited oldWidget) =>
      oldWidget.content != content;
}
