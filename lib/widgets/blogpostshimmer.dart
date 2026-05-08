import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BlogPostShimmer extends StatelessWidget {
  const BlogPostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,

      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),

          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade700,

            child: Column(
              children: [
                /// IMAGE SHIMMER
                Container(
                  height: 200,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(38),
                  ),
                ),

                const SizedBox(height: 10),

                /// CONTENT CARD
                Container(
                  width: double.infinity,
                  height: 350,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(25),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      /// PROFILE ROW
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,

                            decoration:
                                const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            height: 12,
                            width: 80,
                            color: Colors.white,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// TITLE
                      Container(
                        height: 18,
                        width: 220,
                        color: Colors.white,
                      ),

                      const SizedBox(height: 15),

                      /// CONTENT LINE 1
                      Container(
                        height: 10,
                        width: double.infinity,
                        color: Colors.white,
                      ),

                      const SizedBox(height: 8),

                      /// CONTENT LINE 2
                      Container(
                        height: 10,
                        width: double.infinity,
                        color: Colors.white,
                      ),

                      const SizedBox(height: 8),

                      /// CONTENT LINE 3
                      Container(
                        height: 10,
                        width: 180,
                        color: Colors.white,
                      ),

                      const SizedBox(height: 20),

                      /// DOTS
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: List.generate(
                          10,
                          (i) => Container(
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 3,
                            ),

                            height: 8,
                            width: 8,

                            decoration:
                                const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}