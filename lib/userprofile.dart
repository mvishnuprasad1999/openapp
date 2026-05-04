import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_ui/homepage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:open_ui/riverpod/createprofile_provider.dart';
import 'package:open_ui/widgets/dot_loader.dart'; // 👈 import your DotLoader

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isLoading = false; // 👈 added

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _bottomSheetTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take a Photo',
                    color: const Color(0xFFba1e23),
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _bottomSheetTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Choose from Gallery',
                    color: const Color(0xFF3A7BD5),
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomSheetTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.lexend(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFFba1e23),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      if (croppedFile != null) {
        setState(() => _selectedImage = File(croppedFile.path));
      }
    }
  }

  void _removeImage() => setState(() => _selectedImage = null);

  void _onExplorePressed() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || username.isEmpty || title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true); // 👈 show loader

    final notifier = ref.read(profileProvider.notifier);

    await notifier.createProfile(
      name: name,
      username: username,
      title: title,
      description: description,
      image: _selectedImage,
    );

    final state = ref.read(profileProvider);

    if (state.error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() => _isLoading = false); // 👈 hide loader on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Deep background gradient
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
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Subtle red glow top
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFba1e23).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // Top bar — fixed, never scrolls
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context, true),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white12, width: 1),
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
                                'Set Up Profile',
                                style: GoogleFonts.lexend(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Make it yours',
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

                    // Scrollable area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 32),
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // ── Avatar ──
                              Center(
                                child: Stack(
                                  children: [
                                    // Glow ring
                                    Container(
                                      width: 116,
                                      height: 116,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            const Color(0xFFba1e23),
                                            const Color(0xFF3A7BD5),
                                            const Color(0xFFba1e23),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 3,
                                      left: 3,
                                      child: Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF1A1A1A),
                                          image: _selectedImage != null
                                              ? DecorationImage(
                                                  image: FileImage(_selectedImage!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: _selectedImage == null
                                            ? Icon(
                                                Icons.person_rounded,
                                                size: 52,
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                              )
                                            : null,
                                      ),
                                    ),

                                    // Add / Remove button
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: _selectedImage == null
                                            ? _showImageSourceActionSheet
                                            : _removeImage,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: _selectedImage == null
                                                ? const Color(0xFFba1e23)
                                                : const Color(0xFF2C2C2E),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF0D0D0D),
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Icon(
                                            _selectedImage == null
                                                ? Icons.add_rounded
                                                : Icons.close_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // ── Fields ──
                              _buildLabel('Full Name'),
                              const SizedBox(height: 8),
                              _buildField(
                                hint: 'e.g. John Doe',
                                controller: _nameController,
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Username'),
                              const SizedBox(height: 8),
                              _buildField(
                                hint: '@your_name',
                                controller: _usernameController,
                                icon: Icons.alternate_email_rounded,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Profile Title'),
                              const SizedBox(height: 8),
                              _buildField(
                                hint: 'e.g. Designer · Developer · Creator',
                                controller: _titleController,
                                icon: Icons.badge_outlined,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('About You'),
                              const SizedBox(height: 8),
                              _buildField(
                                hint: 'Write a short bio about yourself...',
                                controller: _descriptionController,
                                icon: Icons.notes_rounded,
                                height: 120,
                                maxLines: 5,
                              ),

                              const SizedBox(height: 36),

                              // ── Button ──
                              GestureDetector(
                                onTap: _isLoading ? null : _onExplorePressed, // 👈 disable tap while loading
                                child: Container(
                                  width: double.infinity,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFba1e23),
                                        Color(0xFF8B0000),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFba1e23)
                                            .withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                  // 👇 only this child changes — loader vs normal content
                                  child: _isLoading
                                      ? const DotLoader()
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Let's Explore",
                                              style: GoogleFonts.lexend(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.5,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    double height = 56,
    int maxLines = 1,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: maxLines > 1 ? 14 : 0,
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
            child: Icon(icon, color: const Color(0xFFba1e23), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: const Color(0xFFba1e23),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: GoogleFonts.lexend(
                  color: Colors.white24,
                  fontSize: 13,
                ),
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: maxLines == 1 ? 2 : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}