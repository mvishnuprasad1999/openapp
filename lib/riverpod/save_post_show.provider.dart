import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';


final savedPostsListProvider =
    FutureProvider<List<dynamic>>((ref) async {

  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString("token");

  if (token == null) {
    return [];
  }

 return SavePostShowApi.getSavedPosts(
  token: token,
);
});