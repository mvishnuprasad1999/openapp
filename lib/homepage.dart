import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_ui/blogpostcard.dart';
import 'package:open_ui/postupload.dart';
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

  void onTabChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),

      appBar: AppBar(
        backgroundColor: const Color(0xFF191919),
        centerTitle: false, 
        elevation: 0,
        title: SvgPicture.asset('assets/images/openlogo.svg', height: 32),
      ),

      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: 5,
            itemBuilder: (context, index) {
              return BlogPosImagetCard();
            },
          ),

          CustomBottomBar(selectedIndex: selectedIndex),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 50),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostUploadScreen()),
            );
          },
          backgroundColor: const Color(0xFFE91313),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
