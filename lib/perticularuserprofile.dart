import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_ui/folloedusershow.dart';
import 'package:open_ui/otheruserfollowed.dart';
import 'package:open_ui/perticularuserposts.dart';
import 'package:open_ui/riverpod/Perticular_profile_show_provider.dart';

class PerticularProfileShowScreen extends ConsumerWidget {
  final int userId;

  const PerticularProfileShowScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileShowProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.red)),

        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        data: (user) {
          return Stack(
            children: [
              // BACKGROUND
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A0000),
                      Color(0xFF0D0D0D),
                      Color(0xFF0A0A0A),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // TOP BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white12,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? "",
                                style: GoogleFonts.lexend(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Profile",
                                style: GoogleFonts.lexend(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // PROFILE IMAGE
                    Center(
                      child: Container(
                        width: 116,
                        height: 116,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Color(0xFF3A7BD5),
                              Color(0xFF6A3DE8),
                              Color(0xFFba1e23),
                              Color(0xFF3A7BD5),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: Image.network(
                                user.profileImage ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF1A1A1A),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 52,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BUTTON 1 - FOLLOWING
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OtherFollowingScreen(userId: user.id,),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A3DE8), Color(0xFF3A7BD5)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Following",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BUTTON 2 - POSTS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserPostsScreen(userId: userId),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFba1e23), Color(0xFF6A3DE8)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.article_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Posts (${user.posts?.length ?? 0})",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FIELDS
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _field(
                                "Name",
                                user.name,
                                Icons.badge_outlined,
                                false,
                              ),
                              _field(
                                "Username",
                                "@${user.username}",
                                Icons.alternate_email_rounded,
                                false,
                              ),
                              _field(
                                "Email",
                                user.email,
                                Icons.email_rounded,
                                true,
                              ),
                              _field(
                                "Profile Title",
                                user.profileTitle,
                                Icons.work_outline_rounded,
                                false,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "About",
                                style: GoogleFonts.lexend(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  minHeight: 120,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C1C1E),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white10),
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFba1e23),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(
                                        Icons.notes_rounded,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        user.profileDescription ?? "",
                                        textAlign: TextAlign.justify,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(String label, String? value, IconData icon, bool iconBg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconBg
                    ? Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFba1e23),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(icon, color: Colors.white, size: 15),
                      )
                    : Icon(icon, color: const Color(0xFFba1e23)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value ?? "",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}