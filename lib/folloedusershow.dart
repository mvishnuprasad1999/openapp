import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_ui/perticularuserprofile.dart';
import 'package:open_ui/riverpod/followinguser_provider.dart';

class UserFollowingScreen extends ConsumerStatefulWidget {
  final int userId;

  const UserFollowingScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UserFollowingScreen> createState() =>
      _UserFollowingScreenState();
}

class _UserFollowingScreenState extends ConsumerState<UserFollowingScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(followingProvider.notifier).loadFollowing();
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(followingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Following",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: users.isEmpty
          ? Center(
              child: Text(
                "No following users",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withOpacity(0.08),
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final user = users[index];

                final hasImage = user.profileImage != null &&
                    user.profileImage!.isNotEmpty;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerticularProfileShowScreen(
                          userId: user.id,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage:
                        hasImage ? NetworkImage(user.profileImage!) : null,
                    child: hasImage
                        ? null
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                  title: Text(
                    user.username ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    user.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  trailing: SizedBox(
                    height: 34,
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(followingProvider.notifier)
                            .unfollowUser(user.id);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF262626),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Unfollow",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
