import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/services/createprofileapi.dart';

import 'auth_provider.dart';

class ProfileState {
  final bool isLoading;
  final String? error;

  ProfileState({
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => ProfileState();

  Future<void> createProfile({
    required String name,
    required String username,
    required String title,
    required String description,
    File? image,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final token = ref.read(authProvider).token;
      if (token == null) throw Exception("User not logged in");

      await CreateProfileApi.createProfile(
        name:name ,
        token: token,
        username: username,
        title: title,
        description: description,
        imageFile: image,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();

});

