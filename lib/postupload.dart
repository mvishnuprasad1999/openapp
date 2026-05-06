import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:open_ui/riverpod/auth_provider.dart';
import 'package:open_ui/riverpod/post_upload_provider.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';

// ─── DotLoader ───────────────────────────────────────────────────────────────

class DotLoader extends StatefulWidget {
  final Color activeColor;
  final Color inactiveColor;

  const DotLoader({
    super.key,
    this.activeColor = Colors.blueAccent,
    this.inactiveColor = Colors.white,
  });

  @override
  State<DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final active = (_controller.value * 4).floor() % 4;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final isActive = i == active;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? widget.activeColor : widget.inactiveColor,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: widget.activeColor.withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── PostUploadScreen ─────────────────────────────────────────────────────────

class PostUploadScreen extends ConsumerStatefulWidget {
  const PostUploadScreen({super.key});

  @override
  ConsumerState<PostUploadScreen> createState() => _PostUploadScreenState();
}

class _PostUploadScreenState extends ConsumerState<PostUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<_PickedPostImage> _images = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // ── NEW: tracks upload in-progress ──
  bool _isUploading = false;

  Future<void> _addImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (pickedImage == null) return;

    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: const Color(0xFF181818),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF009DFF),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop image',
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        WebUiSettings(context: context),
      ],
    );

    if (croppedImage == null || !mounted) return;

    setState(() {
      _images.add(
        _PickedPostImage(
          path: croppedImage.path,
          fileName: _fileNameFromPath(croppedImage.path),
        ),
      );
    });
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: 28),
                  _UploadDropZone(onTap: _addImage),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    for (var i = 0; i < _images.length; i++) ...[
                      _ImageFileRow(
                        image: _images[i],
                        onDelete: () => _deleteImage(i),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                  const SizedBox(height: 8),
                  _PostTextField(
                    hintText: 'Post Title',
                    minLines: 2,
                    maxLines: 2,
                    controller: _titleController,
                  ),
                  _PostTextField(
                    hintText: 'post content',
                    minLines: 8,
                    maxLines: 8,
                    controller: _contentController,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      // ── Disabled while uploading ──
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final authState = ref.read(authProvider);

                              if (authState.token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please login first")),
                                );
                                return;
                              }

                              final files =
                                  _images.map((e) => File(e.path)).toList();

                              // ── Show loader ──
                              setState(() => _isUploading = true);

                              try {
                                await ref
                                    .read(postUploadProvider.notifier)
                                    .uploadPost(
                                      token: authState.token!,
                                      title: _titleController.text.trim(),
                                      content: _contentController.text.trim(),
                                      files: files,
                                    );
                                    ref.invalidate(postsProvider);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Post uploaded successfully"),
                                          
                                    ),
                                  );

                                  setState(() {
                                    _images.clear();
                                    _titleController.clear();
                                    _contentController.clear();
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              } finally {
                                // ── Hide loader ──
                                if (mounted) {
                                  setState(() => _isUploading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF271B96),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        // Keep button style identical; disabledBackgroundColor
                        // matches so it looks the same while loading.
                        disabledBackgroundColor: const Color(0xFF271B96),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      // ── Swap label ↔ loader ──
                      child: _isUploading
                          ? const DotLoader(
                              activeColor: Color(0xFFFF2130), // red
                              inactiveColor: Colors.white,
                            )
                          : const Text(
                              'post upload',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 28,
              bottom: 24,
              child: FloatingActionButton.small(
                onPressed: _addImage,
                backgroundColor: const Color(0xFFFF242F),
                foregroundColor: Colors.white,
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 1),
                ),
                child:
                    const Icon(Icons.add_photo_alternate_outlined, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fileNameFromPath(String path) {
  final normalizedPath = path.replaceAll(r'\', '/');
  return normalizedPath.split('/').last;
}

class _PickedPostImage {
  const _PickedPostImage({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

// ─── Sub-widgets (unchanged) ──────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF242424),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF555555), width: 1),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 18),
        const Text(
          'Post content on open',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  const _UploadDropZone({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 225,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(42),
          border: Border.all(color: const Color(0xFFFF2130), width: 4),
          boxShadow: const [
            BoxShadow(color: Color(0xFF00A7FF), spreadRadius: 3),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFA7A7A7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.upload, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload images for post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  color: Color(0xFFD1D1D1),
                  fontSize: 11,
                  height: 1.25,
                ),
                children: [
                  TextSpan(text: 'supported files '),
                  TextSpan(
                    text: 'jpg',
                    style: TextStyle(color: Color(0xFF009DFF)),
                  ),
                  TextSpan(text: ' format maximum up to\n'),
                  TextSpan(
                    text: '5',
                    style: TextStyle(color: Color(0xFF009DFF)),
                  ),
                  TextSpan(text: ' images'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFileRow extends StatelessWidget {
  const _ImageFileRow({required this.image, required this.onDelete});

  final _PickedPostImage image;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              File(image.path),
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              image.fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF009DFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 30),
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFF2530),
              size: 19,
            ),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

class _PostTextField extends StatelessWidget {
  const _PostTextField({
    required this.hintText,
    required this.minLines,
    required this.maxLines,
    this.controller,
  });

  final String hintText;
  final int minLines;
  final int maxLines;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: const Color(0xFF009DFF),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF009DFF),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFF2B2B2B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF009DFF), width: 1),
        ),
      ),
    );
  }
}