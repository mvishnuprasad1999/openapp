import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/model/createpostmodel.dart';
import 'package:open_ui/services/postshowapi.dart';

final postsProvider = FutureProvider<List<Post>>((ref) async {
  return PostApi.getPosts();
});