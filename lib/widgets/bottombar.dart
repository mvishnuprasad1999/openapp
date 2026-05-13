// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:open_ui/mypostscreen.dart';
// import 'package:open_ui/profileshowscreen.dart';
// import 'package:open_ui/savedpostscreen.dart';
// import '../homepage.dart';

// class CustomBottomBar extends StatefulWidget {
//   final int selectedIndex;

//   const CustomBottomBar({super.key, required this.selectedIndex});

//   @override
//   State<CustomBottomBar> createState() => _CustomBottomBarState();
// }

// class _CustomBottomBarState extends State<CustomBottomBar> {
//   static const Color activeOrange = Color(0xFF2F88FF);
//   static const Color barColor = Color(0xFF1B1C20);
//   static const Color inactiveGrey = Color(0xFFC6C6C6);

//   final List<String> inactiveIcons = [
//     "assets/images/h1.svg",
//     "assets/images/h2.svg",
//     "assets/images/h3.svg",
//     "assets/images/h4.svg",
//     "assets/images/h5.svg",
//   ];

//   final List<String> activeIcons = [
//     "assets/images/a1.svg",
//     "assets/images/a2.svg",
//     "assets/images/a3.svg",
//     "assets/images/a4.svg",
//     "assets/images/a5.svg",
//   ];

//   void onItemTapped(int index) {
//     if (index == widget.selectedIndex) return;

//     switch (index) {
//       case 0:
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 0)),
//           (route) => false,
//         );
//         break;

//       case 1:
//         //  Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (_) => const MyPostsScreen()),
//         // );
//         break;

//       case 2:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const SavedPostsScreen()),
//         );
//         break;

//       case 3:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfileShowScreen()),
//         );
//         break;

//       case 4:
//         // TODO: Profile page
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedIndex = widget.selectedIndex;
//     final barWidth = MediaQuery.of(context).size.width * 0.82;
//     final itemWidth = barWidth / inactiveIcons.length;

//     return Positioned(
//       bottom: 20,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: Container(
//           width: barWidth,
//           height: 82,
//           decoration: BoxDecoration(
//             color: barColor,
//             borderRadius: BorderRadius.circular(32),
//             border: Border.all(color: Colors.white.withOpacity(.6), width: 6),
//           ),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Row(
//                 children: List.generate(inactiveIcons.length, (index) {
//                   final isActive = selectedIndex == index;

//                   return Expanded(
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: () => onItemTapped(index),
//                       child: Center(
//                         child: AnimatedOpacity(
//                           duration: const Duration(milliseconds: 180),
//                           opacity: isActive ? 0 : 1,
//                           child: SvgPicture.asset(
//                             inactiveIcons[index],
//                             height: 30,
//                             // colorFilter: const ColorFilter.mode(
//                             //   inactiveGrey,
//                             //   BlendMode.srcIn,
//                             // ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 220),
//                 curve: Curves.easeOut,
//                 left: (itemWidth * selectedIndex) + ((itemWidth - 64) / 2),
//                 top: -20,
//                 child: GestureDetector(
//                   onTap: () => onItemTapped(selectedIndex),
//                   child: Container(
//                     width: 64,
//                     height: 64,
//                     decoration: BoxDecoration(
//                       color: activeOrange,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.35),
//                           blurRadius: 18,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: SvgPicture.asset(
//                         activeIcons[selectedIndex],
//                         height: 38,
//                         // colorFilter: const ColorFilter.mode(
//                         //   Colors.white,
//                         //   BlendMode.srcIn,
//                         // ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_ui/folloedusershow.dart';
import 'package:open_ui/mypostscreen.dart';
import 'package:open_ui/otheruserfollowed.dart';
import 'package:open_ui/perticularuserprofile.dart';
import 'package:open_ui/profileshowscreen.dart';
import 'package:open_ui/savedpostscreen.dart';
import '../homepage.dart';

class CustomBottomBar extends StatefulWidget {
  final int selectedIndex;

  const CustomBottomBar({super.key, required this.selectedIndex});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  static const Color glassBlue = Color(0xFF2F88FF);
  static const Color redIcon = Color(0xFFFF2D2D);

  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  final List<String> inactiveIcons = [
    "assets/images/h1.svg",
    "assets/images/h2.svg",
    "assets/images/h3.svg",
    "assets/images/h4.svg",
    "assets/images/h5.svg",
  ];

  final List<String> activeIcons = [
    "assets/images/a1.svg",
    "assets/images/a2.svg",
    "assets/images/a3.svg",
    "assets/images/a4.svg",
    "assets/images/a5.svg",
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    if (index == widget.selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 0)),
          (route) => false,
        );
        break;
      case 1:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => const FollowingScreen()),
        // );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedPostsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileShowScreen()),
        );
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selectedIndex;
    final barWidth = MediaQuery.of(context).size.width * 0.82;
    final itemWidth = barWidth / inactiveIcons.length;
    const barH = 74.0;
    const bubbleD = 66.0;
    const lift = 16.0;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: barWidth,
          height: barH + lift,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Frosted glass bar ─────────────────────────────────────
              Positioned(
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      width: barWidth,
                      height: barH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white.withOpacity(0.07),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.40),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.10),
                            blurRadius: 0,
                            spreadRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // glass sheen
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.10),
                                    Colors.transparent,
                                    const Color(0xFF64A0FF).withOpacity(0.04),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // inactive icons row
                          Row(
                            children: List.generate(inactiveIcons.length, (i) {
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => onItemTapped(i),
                                  child: Center(
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      opacity: sel == i ? 0.0 : 1.0,
                                      child: SvgPicture.asset(
                                        inactiveIcons[i],
                                        height: 26,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Blue frosted glass bubble ─────────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: itemWidth * sel + (itemWidth - bubbleD) / 2,
                top: 0,
                child: GestureDetector(
                  onTap: () => onItemTapped(sel),
                  child: SizedBox(
                    width: bubbleD,
                    height: bubbleD,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // pulsing blue glow ring
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => Transform.scale(
                            scale: _pulseAnim.value,
                            child: Container(
                              width: bubbleD + 16,
                              height: bubbleD + 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    glassBlue.withOpacity(0.22),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // frosted blue glass sphere
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              width: bubbleD,
                              height: bubbleD,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: glassBlue.withOpacity(0.30),
                                border: Border.all(
                                  color: const Color(
                                    0xFF64BEFF,
                                  ).withOpacity(0.60),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: glassBlue.withOpacity(0.50),
                                    blurRadius: 32,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: glassBlue.withOpacity(0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // subtle blue sheen — no highlights
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment(-0.8, -0.9),
                                end: Alignment(0.6, 0.9),
                                colors: [
                                  Color(0x28A0DCFF),
                                  Color(0x062F88FF),
                                  Color(0x121440C8),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // red active icon — clean, no highlight blobs
                        SvgPicture.asset(
                          activeIcons[sel],
                          height: 30,
                          // colorFilter: const ColorFilter.mode(
                          //   redIcon,
                          //   BlendMode.srcIn,
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
