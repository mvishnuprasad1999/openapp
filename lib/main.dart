import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:open_ui/aichatscreen.dart';
import 'package:open_ui/authenticationscreen.dart';
import 'package:open_ui/widgets/blogpostshimmer.dart';
// import 'package:open_ui/postupload.dart';
// import 'package:open_ui/userprofile.dart';
// import 'package:open_ui/profileshowscreen.dart';

// import 'package:open_ui/userprofile.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.lexendTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home:
      // PostUploadScreen(),
      // ProfileSetupScreen(),
      // ProfileShowScreen(),
      // CompanionScreen(),
      // BlogPostShimmer(),

      const AuthScreen(isLogin: false), // ← start on auth screen
    );
  }
}