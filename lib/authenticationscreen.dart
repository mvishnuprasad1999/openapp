// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:open_ui/homepage.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:open_ui/riverpod/auth_provider.dart';

// class AuthScreen extends ConsumerStatefulWidget {
//   final bool isLogin;
//   const AuthScreen({super.key, this.isLogin = false});

//   @override
//   ConsumerState<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends ConsumerState<AuthScreen> {
//   late bool _isLogin;

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _isLogin = widget.isLogin;
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _toggleMode() => setState(() => _isLogin = !_isLogin);

//   void _handleSubmit() async {
//     final auth = ref.read(authProvider.notifier);

//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       return;
//     }

//     if (_isLogin) {
//       await auth.login(
//         _emailController.text,
//         _passwordController.text,
//       );
//     } else {
//       await auth.signup(
//         _emailController.text,
//         _passwordController.text,
//       );
//     }

//     final state = ref.read(authProvider);

//     if (state.token != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomePage()),
//       );
//     }
//   }

//   Widget _whiteToRedText(String text, double size, FontWeight weight) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => const LinearGradient(
//         colors: [Colors.white, Color(0xFFFF0000)],
//       ).createShader(bounds),
//       child: Text(
//         text,
//         style: GoogleFonts.lexend(
//           fontSize: size,
//           fontWeight: weight,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _whiteToBlueText(String text, double size, FontWeight weight) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => const LinearGradient(
//         colors: [Colors.white, Color(0xFF2092E4)],
//       ).createShader(bounds),
//       child: Text(
//         text,
//         style: GoogleFonts.lexend(
//           fontSize: size,
//           fontWeight: weight,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.black,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFFC92828),
//                   Color(0xFF4A0707),
//                   Color(0xFF000000),
//                 ],
//                 stops: [0.0, 0.22, 1.0],
//               ),
//             ),
//           ),

//           SafeArea(
//             child: SingleChildScrollView(
//               keyboardDismissBehavior:
//                   ScrollViewKeyboardDismissBehavior.onDrag,
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Column(
//                 children: [
//                   // Logo
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.45,
//                     child: Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 40),
//                         child: SvgPicture.asset(
//                           'assets/images/openlogosignscreen.svg',
//                           width: double.infinity,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Card
//                   Container(
//                     margin: const EdgeInsets.fromLTRB(27, 0, 27, 27),
//                     decoration: BoxDecoration(
//                       color: Colors.transparent,
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(color: Colors.white),
//                     ),
//                     padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Wrap(
//                           children: [
//                             Text(
//                               'Welcome to ',
//                               style: GoogleFonts.lexend(
//                                 color: Colors.white,
//                                 fontSize: 29.5,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             _whiteToRedText('open', 29.5, FontWeight.bold),
//                           ],
//                         ),

//                         const SizedBox(height: 6),

//                         _whiteToRedText(
//                           _isLogin ? 'Login' : 'Signup',
//                           20,
//                           FontWeight.w600,
//                         ),

//                         const SizedBox(height: 18),

//                         _buildTextField(
//                           controller: _emailController,
//                           hint: 'enter your email',
//                         ),

//                         const SizedBox(height: 12),

//                         _buildTextField(
//                           controller: _passwordController,
//                           hint: 'enter password',
//                           obscureText: true,
//                         ),

//                         const SizedBox(height: 18),

//                         SizedBox(
//                           width: double.infinity,
//                           height: 44,
//                           child: DecoratedBox(
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [
//                                   Color(0xFFE62961),
//                                   Color(0xFFFF0000),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: TextButton(
//                               onPressed: _handleSubmit, // ✅ fixed
//                               child: Text(
//                                 _isLogin ? 'LOGIN' : 'SIGNUP',
//                                 style: GoogleFonts.lexend(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 2,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 14),

//                         Row(
//                           children: [
//                             _whiteToBlueText('OR  ', 15, FontWeight.w500),
//                             GestureDetector(
//                               onTap: _toggleMode,
//                               child: _whiteToBlueText(
//                                 _isLogin ? 'Signup' : 'Login',
//                                 15,
//                                 FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 14),

//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(top: 5),
//                               child: SvgPicture.asset(
//                                 'assets/images/tick.svg',
//                                 width: 16,
//                                 height: 16,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'By Signup/logging accepting our terms and conditions ........',
//                                 style: GoogleFonts.lexend(
//                                   color: Colors.white.withOpacity(0.8),
//                                   fontSize: 11,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     bool obscureText = false,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(5),
//         border: Border.all(
//           color: const Color(0xFF605E5E).withOpacity(0.5),
//         ),
//       ),
//       child: TextField(
//         controller: controller,
//         obscureText: obscureText,
//         style: GoogleFonts.lexend(
//           color: Colors.black87,
//           fontSize: 13,
//         ),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: GoogleFonts.lexend(
//             color: const Color(0xFF9E9E9E),
//             fontSize: 13,
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:open_ui/homepage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_ui/homepage.dart';
import 'package:open_ui/riverpod/auth_provider.dart';
import 'package:open_ui/userprofile.dart';
import 'package:open_ui/widgets/dot_loader.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = false});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isLogin;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() => setState(() => _isLogin = !_isLogin);

  void _handleSubmit() async {
    final auth = ref.read(authProvider.notifier);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    if (_isLogin) {
      await auth.login(_emailController.text, _passwordController.text);
    } else {
      await auth.signup(_emailController.text, _passwordController.text);
    }

    if (!mounted) return; // ✅ safe context check

    final state = ref.read(authProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error!,
            style: GoogleFonts.lexend(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

if (state.token != null) {
  if (_isLogin) {
    // ✅ LOGIN → go to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } else {
    // ✅ SIGNUP → go to Profile Setup
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
  }
}
  }

  Widget _whiteToRedText(String text, double size, FontWeight weight) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFFF0000)],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: size,
          fontWeight: weight,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _whiteToBlueText(String text, double size, FontWeight weight) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFF2092E4)],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: size,
          fontWeight: weight,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider); // ✅ watch for loading/error

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFC92828),
                  Color(0xFF4A0707),
                  Color(0xFF000000),
                ],
                stops: [0.0, 0.22, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Logo
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: SvgPicture.asset(
                          'assets/images/openlogosignscreen.svg',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Card
                  Container(
                    margin: const EdgeInsets.fromLTRB(27, 0, 27, 27),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          children: [
                            Text(
                              'Welcome to ',
                              style: GoogleFonts.lexend(
                                color: Colors.white,
                                fontSize: 29.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _whiteToRedText('open', 29.5, FontWeight.bold),
                          ],
                        ),

                        const SizedBox(height: 6),

                        _whiteToRedText(
                          _isLogin ? 'Login' : 'Signup',
                          20,
                          FontWeight.w600,
                        ),

                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _emailController,
                          hint: 'enter your email',
                        ),

                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _passwordController,
                          hint: 'enter password',
                          obscureText: true,
                        ),

                        const SizedBox(height: 18),

                        // ✅ Button with loading state
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE62961), Color(0xFFFF0000)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: authState.isLoading
                                ? const Center(
                                    child: DotLoader(),
                                  ) // ✅ dots inside gradient box
                                : TextButton(
                                    onPressed: _handleSubmit,
                                    child: Text(
                                      _isLogin ? 'LOGIN' : 'SIGNUP',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            _whiteToBlueText('OR  ', 15, FontWeight.w500),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: _whiteToBlueText(
                                _isLogin ? 'Signup' : 'Login',
                                15,
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: SvgPicture.asset(
                                'assets/images/tick.svg',
                                width: 16,
                                height: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'By Signup/logging accepting our terms and conditions ........',
                                style: GoogleFonts.lexend(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF605E5E).withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.lexend(color: Colors.black87, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(
            color: const Color(0xFF9E9E9E),
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
