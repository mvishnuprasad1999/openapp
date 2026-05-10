import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/model/createpostshowmodel.dart';
import 'package:open_ui/services/api_services.dart';


final postsProvider = FutureProvider<List<Post>>((ref) async {
  return PostApi.getPosts();
});