import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_ui/model/user_model.dart';
import 'package:open_ui/services/api_services.dart';

/// ===============================
/// PROVIDER
/// ===============================

final otherFollowingProvider =
    FutureProvider.family<List<UserModel>, int>((ref, userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) {
    throw Exception("Token not found");
  }

  return FollowApi.getUserFollowing(
    userId: userId,
    token: token,
  );
});

class OtherFollowingScreen extends ConsumerStatefulWidget {
  final int userId;

  const OtherFollowingScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<OtherFollowingScreen> createState() =>
      _OtherFollowingScreenState();
}

class _OtherFollowingScreenState extends ConsumerState<OtherFollowingScreen> {
  List<UserModel> localUsers = [];
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    final followingAsync = ref.watch(
      otherFollowingProvider(widget.userId),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Following",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: followingAsync.when(
        data: (users) {
          if (!initialized) {
            localUsers = List<UserModel>.from(users);
            initialized = true;
          }

          if (localUsers.isEmpty) {
            return Center(
              child: Text(
                "No following users",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }

          return ListView.separated(
            itemCount: localUsers.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.grey.shade900,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final user = localUsers[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: user.profileImage != null &&
                              user.profileImage!.isNotEmpty
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null ||
                              user.profileImage!.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username ?? "unknown_user",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name ?? "",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (e, _) => Center(
          child: Text(
            "Unable to load following users",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
