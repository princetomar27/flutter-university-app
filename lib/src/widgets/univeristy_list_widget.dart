import 'package:flutter/material.dart';
import 'package:fluttertask/src/models/university.dart';
import 'package:fluttertask/src/widgets/university_card.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversitiesListWidget extends StatelessWidget {
  final List<University> universities;
  final void Function(String)? onUniversityTap;
  final void Function(String)? onWebsiteTap;

  const UniversitiesListWidget({
    super.key,
    required this.universities,
    this.onUniversityTap,
    this.onWebsiteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (universities.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList.builder(
        itemCount: universities.length,
        itemBuilder: (context, index) {
          final university = universities[index];

          return RepaintBoundary(
            key: ValueKey(university.name), // Important for performance
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: UniversityCard(
                university: university,
                onTap: () {
                  if (onUniversityTap != null) {
                    onUniversityTap!(university.name);
                  } else {
                    // Default navigation behavior
                    context.pushNamed(
                      'university_detail',
                      pathParameters: {'name': university.name},
                    );
                  }
                },
                onWebsiteTap: () {
                  if (university.website != null) {
                    if (onWebsiteTap != null) {
                      onWebsiteTap!(university.website!);
                    } else {
                      // Default website opening behavior
                      _openWebsite(university.website!);
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
