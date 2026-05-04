import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_ui/profileshowscreen.dart';
import '../homepage.dart';

class CustomBottomBar extends StatefulWidget {
  final int selectedIndex; // active tab from parent

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  // Inactive icons (white)
  final List<String> inactiveIcons = [
    "assets/images/h1.svg",
    "assets/images/h2.svg",
    "assets/images/h3.svg",
    "assets/images/h4.svg",
    "assets/images/h5.svg",
  ];

  // Active icons (colored)
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
          MaterialPageRoute(
            builder: (_) => const HomePage(initialIndex: 0),
          ),
          (route) => false,
        );
        break;

      case 1:
        // TODO: Search page
        break;

      case 2:
        // TODO: Add page
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

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.black,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isActive = selectedIndex == index;

              return GestureDetector(
                onTap: () => onItemTapped(index),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(
                      isActive
                          ? activeIcons[index]
                          : inactiveIcons[index],
                      key: ValueKey('${index}_$isActive'),
                      height: 24,
                      colorFilter: isActive
                          ? null
                          : const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}