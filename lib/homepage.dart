import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_ui/aichatscreen.dart';
import 'package:open_ui/blogpostcard.dart';
import 'package:open_ui/postupload.dart';
import 'package:open_ui/taskscreen.dart';
import 'package:open_ui/widgets/bottombar.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      // Colors.black12,
      Color(0xFF191919),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black12,
        //  Color(0xFF191919),
        centerTitle: false,
        elevation: 0,
        title: SvgPicture.asset('assets/images/openlogo.svg', height: 32),
      ),

      body: Stack(
        children: [
          // 🔹 Scroll Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child:const BlogPosImagetCard(),
          ),

          // 🔹 Bottom Bar
          CustomBottomBar(selectedIndex: selectedIndex),

          // 🔴 MAIN FAB (Red)
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              heroTag: "mainFab",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostUploadScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFFE91313),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),

          // 🟣 SECOND FAB (Pink - Above)
          Positioned(
            bottom: 190,
            right: 24,
            child: GestureDetector(
              onTap:(){
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(),
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/images/c.svg',
                width: 48,
                height: 48,
                // ✅ No colorFilter needed — colors are already in the SVG
              ),
            ),
          ),
        ],
      ),
    );
  }
}
