import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_ui/folloedusershow.dart';
import 'package:open_ui/homepage.dart';
import 'package:open_ui/mypostscreen.dart';
import 'package:open_ui/riverpod/profileshow_provider.dart';

import '../widgets/bottombar.dart';

class ProfileShowScreen extends ConsumerWidget {
  const ProfileShowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileShowingProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFba1e23)),
        ),
      ),

      error: (err, _) => Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Center(
          child: Text(
            "Error: $err",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),

      data: (user) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: Stack(
            children: [
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
                    // ── Top Bar ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const HomePage(initialIndex: 0),
                              ),
                              (route) => false,
                            ),
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
                                'Your Profile',
                                style: GoogleFonts.lexend(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Your Identity',
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

                    // ── BUTTON 1 - FOLLOWING ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserFollowingScreen(userId: 3),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6A3DE8),
                                Color(0xFF3A7BD5),
                              ],
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

                    // ── BUTTON 2 - MY POSTS ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyPostsScreen(userId: 3),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFba1e23),
                                Color(0xFF6A3DE8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "My Posts",
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

                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Name'),
                              const SizedBox(height: 8),
                              _buildReadField(
                                value: user.name ?? "No Name",
                                icon: Icons.badge_outlined,
                              ),

                              const SizedBox(height: 20),

                              _buildLabel('Username'),
                              const SizedBox(height: 8),
                              _buildReadField(
                                value: user.username ?? "No Username",
                                icon: Icons.alternate_email_rounded,
                              ),

                              const SizedBox(height: 20),

                              _buildLabel('Email'),
                              const SizedBox(height: 8),
                              _buildReadField(
                                value: user.email,
                                icon: Icons.email_rounded,
                                iconBg: true,
                              ),

                              const SizedBox(height: 20),

                              _buildLabel('Profile Title'),
                              const SizedBox(height: 8),
                              _buildReadField(
                                value: user.profileTitle ?? "Not added",
                                icon: Icons.work_outline_rounded,
                              ),

                              const SizedBox(height: 20),

                              _buildLabel('About You'),
                              const SizedBox(height: 8),
                              _buildReadField(
                                value: user.profileDescription ??
                                    "No description",
                                icon: Icons.notes_rounded,
                                multiLine: true,
                                iconBg: true,
                                justified: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              CustomBottomBar(selectedIndex: 3),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildReadField({
    required String value,
    required IconData icon,
    bool multiLine = false,
    bool iconBg = false,
    bool justified = false,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: multiLine ? 120 : 56),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: EdgeInsets.all(multiLine ? 14 : 10),
      child: Row(
        crossAxisAlignment: multiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
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
              value,
              textAlign: justified ? TextAlign.justify : TextAlign.start,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}