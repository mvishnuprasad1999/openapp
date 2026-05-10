import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_ui/mypostscreen.dart';
import 'package:open_ui/profileshowscreen.dart';
import 'package:open_ui/savedpostscreen.dart';
import '../homepage.dart';

class CustomBottomBar extends StatefulWidget {
  final int selectedIndex;

  const CustomBottomBar({super.key, required this.selectedIndex});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  static const Color activeOrange = Color(0xFF2F88FF);
  static const Color barColor = Color(0xFF1B1C20);
  static const Color inactiveGrey = Color(0xFFC6C6C6);

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
        //  Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => const MyPostsScreen()),
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
        // TODO: Profile page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.selectedIndex;
    final barWidth = MediaQuery.of(context).size.width * 0.82;
    final itemWidth = barWidth / inactiveIcons.length;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: barWidth,
          height: 82,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(.6), width: 6),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: List.generate(inactiveIcons.length, (index) {
                  final isActive = selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onItemTapped(index),
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: isActive ? 0 : 1,
                          child: SvgPicture.asset(
                            inactiveIcons[index],
                            height: 30,
                            // colorFilter: const ColorFilter.mode(
                            //   inactiveGrey,
                            //   BlendMode.srcIn,
                            // ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: (itemWidth * selectedIndex) + ((itemWidth - 64) / 2),
                top: -20,
                child: GestureDetector(
                  onTap: () => onItemTapped(selectedIndex),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: activeOrange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        activeIcons[selectedIndex],
                        height: 38,
                        // colorFilter: const ColorFilter.mode(
                        //   Colors.white,
                        //   BlendMode.srcIn,
                        // ),
                      ),
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
