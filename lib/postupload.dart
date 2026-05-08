import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_ui/riverpod/auth_provider.dart';
import 'package:open_ui/riverpod/post_upload_provider.dart';
import 'package:open_ui/riverpod/postshowprovider.dart';

/// ───────────────── DOT LOADER ─────────────────

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
                        ),
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

/// ───────────────── SCREEN ─────────────────

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

  bool _isUploading = false;

  /// IMAGE SIZE CHECK
  Future<bool> _isValidImageSize(String path) async {
    final file = File(path);

    final bytes = await file.readAsBytes();

    final codec = await ui.instantiateImageCodec(bytes);

    final frame = await codec.getNextFrame();

    final image = frame.image;

    final width = image.width;
    final height = image.height;

    final ratio = width / height;

    /// 400x200 ≈ 2.0 ratio
    return ratio >= 1.6 && ratio <= 2.3;
  }

  Future<void> _addImage() async {
    if (_images.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed')));

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
        ),
        IOSUiSettings(title: 'Crop image'),
        WebUiSettings(context: context),
      ],
    );

    if (croppedImage == null || !mounted) return;

    /// VALIDATION
    final isValid = await _isValidImageSize(croppedImage.path);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image should approximately match 400x200 size ratio'),
        ),
      );

      return;
    }

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
      backgroundColor: const Color(0xFF161616),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),

              const SizedBox(height: 30),

              _UploadDropZone(onTap: _addImage),

              const SizedBox(height: 14),

              if (_images.isNotEmpty)
                for (int i = 0; i < _images.length; i++) ...[
                  _ImageFileRow(
                    image: _images[i],
                    onDelete: () => _deleteImage(i),
                  ),
                  const SizedBox(height: 7),
                ],

              const SizedBox(height: 6),

              _PostTextField(
                hintText: 'Post Title',
                minLines: 2,
                maxLines: 2,
                controller: _titleController,
              ),

              const SizedBox(height: 12),

              _PostTextField(
                hintText: 'post content',
                minLines: 8,
                maxLines: 8,
                controller: _contentController,
              ),

              const SizedBox(height: 10),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 34,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : () async {
                              final title = _titleController.text.trim();
                              final content = _contentController.text.trim();

                              if (_images.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Post failed due to the images or title or content is empty,first check the images',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (title.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Post failed due to the images or title or content is empty,plese check the title'),
                                  ),
                                );
                                return;
                              }

                              if (content.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Post failed due to the images or title or content is empty,please check the content'),
                                  ),
                                );
                                return;
                              }

                              final authState = ref.read(authProvider);

                              if (authState.token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please login first'),
                                  ),
                                );
                                return;
                              }

                              final files = _images
                                  .map((e) => File(e.path))
                                  .toList();

                              setState(() {
                                _isUploading = true;
                              });

                              try {
                                await ref
                                    .read(postUploadProvider.notifier)
                                    .uploadPost(
                                      token: authState.token!,
                                      title: title,
                                      content: content,
                                      files: files,
                                    );

                                ref.invalidate(postsProvider);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Post uploaded successfully',
                                      ),
                                    ),
                                  );

                                  setState(() {
                                    _images.clear();
                                    _titleController.clear();
                                    _contentController.clear();
                                  });
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Upload failed. Please try again',
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isUploading = false;
                                  });
                                }
                              }
                            },

                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF20106F),
                              Color(0xFF3A15C8),
                              Color(0xFF2A0E9E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: _isUploading
                              ? const DotLoader(
                                  activeColor: Colors.red,
                                  inactiveColor: Colors.white,
                                )
                              : const Text(
                                  'post upload',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 12,
                    top: -5,
                    child: FloatingActionButton.small(
                      onPressed: _addImage,
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF242F),
                      shape: const CircleBorder(
                        side: BorderSide(color: Colors.white, width: 1),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ───────────────── HELPERS ─────────────────

String _fileNameFromPath(String path) {
  final normalized = path.replaceAll(r'\', '/');

  return normalized.split('/').last;
}

class _PickedPostImage {
  final String path;
  final String fileName;

  const _PickedPostImage({required this.path, required this.fileName});
}

/// ───────────────── HEADER ─────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF555555)),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        ),

        const SizedBox(width: 18),

        const Text(
          'Post content on open',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// ───────────────── UPLOAD BOX ─────────────────

class _UploadDropZone extends StatelessWidget {
  final VoidCallback onTap;

  const _UploadDropZone({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 230,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: const Color(0xFF009DFF), width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: const Color(0xFFFF1428), width: 5),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(38),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A8A8A),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.upload,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Upload images for post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 2),

                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 11),
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
          ),
        ),
      ),
    );
  }
}

/// ───────────────── IMAGE ROW ─────────────────

class _ImageFileRow extends StatelessWidget {
  final _PickedPostImage image;
  final VoidCallback onDelete;

  const _ImageFileRow({required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              image.fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF009DFF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFF242F),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

/// ───────────────── TEXT FIELD ─────────────────

class _PostTextField extends StatelessWidget {
  final String hintText;
  final int minLines;
  final int maxLines;
  final TextEditingController? controller;

  const _PostTextField({
    required this.hintText,
    required this.minLines,
    required this.maxLines,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF009DFF), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      ),
    );
  }
}
