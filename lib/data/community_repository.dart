import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../models.dart';

/// Anonymous community sharing — no accounts, no payment services.
///
/// Reads/writes the `community_posts` table and the public
/// `community-images` storage bucket (see supabase/community.sql). Every
/// install gets a random device id (stored in SharedPreferences) so posts can
/// be moderated / rate-limited later without user accounts. When Supabase is
/// not configured everything degrades gracefully: reads return empty and
/// [canPost] is false.
class CommunityRepository {
  static const _deviceIdKey = 'suroy_device_id';
  static const _heartedKey = 'suroy_hearted_posts';
  static const _nicknameKey = 'suroy_nickname';

  SupabaseClient get _db => Supabase.instance.client;

  bool get canPost => Env.isConfigured;

  Future<List<CommunityPost>> fetchPosts() async {
    if (!Env.isConfigured) return const [];
    try {
      final rows = await _db
          .from('community_posts')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
      return rows.map(CommunityPost.fromJson).toList(growable: false);
    } catch (e) {
      debugPrint('fetch community_posts failed: $e');
      return const [];
    }
  }

  /// Uploads [imageBytes] (if any) then inserts the post. Returns the created
  /// post, or null on failure.
  Future<CommunityPost?> submitPost({
    required String author,
    required String from,
    required String topic,
    required String body,
    Uint8List? imageBytes,
    String imageExtension = 'jpg',
  }) async {
    if (!canPost) return null;
    try {
      String imageUrl = '';
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final name =
            '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 20)}.$imageExtension';
        await _db.storage.from('community-images').uploadBinary(
              name,
              imageBytes,
              fileOptions: FileOptions(
                contentType: imageExtension == 'png'
                    ? 'image/png'
                    : imageExtension == 'webp'
                        ? 'image/webp'
                        : 'image/jpeg',
              ),
            );
        imageUrl = _db.storage.from('community-images').getPublicUrl(name);
      }

      final row = await _db
          .from('community_posts')
          .insert({
            'author': author,
            'from_label': from,
            'topic': topic,
            'body': body,
            'image_url': imageUrl,
            'device_id': await deviceId(),
          })
          .select()
          .single();
      return CommunityPost.fromJson(row);
    } catch (e) {
      debugPrint('submit community post failed: $e');
      return null;
    }
  }

  /// Bumps the helpful counter (server-side RPC) once per device per post.
  /// Returns true if this device had not hearted the post before.
  Future<bool> markHelpful(String postId) async {
    if (!Env.isConfigured) return false;
    final prefs = await SharedPreferences.getInstance();
    final hearted = prefs.getStringList(_heartedKey) ?? <String>[];
    if (hearted.contains(postId)) return false;
    try {
      await _db.rpc('mark_helpful', params: {'post_id': postId});
      await prefs.setStringList(_heartedKey, [...hearted, postId]);
      return true;
    } catch (e) {
      debugPrint('mark_helpful failed: $e');
      return false;
    }
  }

  Future<bool> hasHearted(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_heartedKey) ?? const []).contains(postId);
  }

  /// Anonymous per-install id, created on first use.
  Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null) {
      final r = Random();
      id = List.generate(4, (_) => r.nextInt(1 << 32).toRadixString(16))
          .join('-');
      await prefs.setString(_deviceIdKey, id);
    }
    return id;
  }

  /// Remembered nickname so users don't retype it each post.
  Future<String> savedNickname() async =>
      (await SharedPreferences.getInstance()).getString(_nicknameKey) ?? '';

  Future<void> saveNickname(String name) async =>
      (await SharedPreferences.getInstance()).setString(_nicknameKey, name);
}
