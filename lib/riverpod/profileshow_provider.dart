import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/services/api_services.dart';
import 'auth_provider.dart';
final profileShowingProvider = FutureProvider<UserModel>((ref) async {
  final authState = ref.watch(authProvider);

  final token = authState.token;

  if (token == null) {
    throw Exception("User not logged in");
  }

  return ProfileShowApi.getProfile(token);
});