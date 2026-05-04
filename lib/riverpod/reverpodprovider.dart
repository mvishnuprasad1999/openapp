import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogChunkParams {
  final String content;
  final double maxWidth;

  BlogChunkParams({
    required this.content,
    required this.maxWidth,
  });
}

final blogChunkProvider =
    Provider.family<List<String>, BlogChunkParams>((ref, params) {
  return _chunkText(params.content, params.maxWidth);
});

List<String> _chunkText(String content, double maxWidth) {
  const int maxLines = 12;

  final words = content.split(' ');
  final chunks = <String>[];

  final tp = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: maxLines,
  );

  String current = '';

  const textStyle = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: Color(0xFF374151),
  );

  for (final word in words) {
    final test = current.isEmpty ? word : '$current $word';

    tp.text = TextSpan(text: test, style: textStyle);
    tp.layout(maxWidth: maxWidth);

    if (tp.didExceedMaxLines) {
      chunks.add(current.trim());
      current = word;
    } else {
      current = test;
    }
  }

  if (current.isNotEmpty) {
    chunks.add(current.trim());
  }

  return chunks;
}