import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/services/api_services.dart';
import 'auth_provider.dart';

final profileShowProvider =
    FutureProvider.family<UserModel, int>((ref, userId) async {
  final authState = ref.watch(authProvider);
  final token = authState.token;

  if (token == null || token.isEmpty) {
    throw Exception("User not logged in");
  }

  return ProfileShowApi.getUserProfile(
    userId: userId,
    token: token,
  );
});