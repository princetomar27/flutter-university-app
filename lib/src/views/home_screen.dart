import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/university_card.dart';
import '../viewmodels/university_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load all universities by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(universityViewModelProvider.notifier)
          .loadAllUniversities(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUniversities() {
    final country = _searchController.text.trim();
    if (country.isNotEmpty) {
      ref
          .read(universityViewModelProvider.notifier)
          .searchUniversities(country);
    }
  }

  void _openWebsite(String url) async {
    try {
      // Ensure URL has proper scheme
      String processedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        processedUrl = 'https://$url';
      }

      final uri = Uri.parse(processedUrl);

      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        final result = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!result && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $processedUrl'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No app found to open $processedUrl'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileViewModelProvider);
    final universityState = ref.watch(universityViewModelProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar Sliver
          SliverAppBar(
            title: const Text('Global University Search'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            elevation: 2,
            floating: true,
            snap: true,
          ),

          // Content Slivers
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // User Profile Card
                UserProfileCard(userProfile: userProfile),

                const SizedBox(height: 24),

                // Search Section
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Search Universities',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Enter Country Name',
                            hintText: 'e.g., India, Japan, USA',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(universityViewModelProvider.notifier)
                                    .clearSearch();
                              },
                            ),
                          ),
                          onSubmitted: (_) => _searchUniversities(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              universityState.isLoading
                                  ? null
                                  : _searchUniversities,
                          icon:
                              universityState.isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.search),
                          label: Text(
                            universityState.isLoading
                                ? 'Searching...'
                                : 'Search Universities',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ]),
            ),
          ),

          // Results Section
          _buildResultsSliver(universityState),
        ],
      ),
    );
  }

  Widget _buildResultsSliver(UniversityState state) {
    if (state.isLoading && state.universities.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading universities...'),
            ],
          ),
        ),
      );
    }

    if (state.error != null && state.universities.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (state.country != null) {
                    _searchUniversities();
                  } else {
                    ref
                        .read(universityViewModelProvider.notifier)
                        .loadAllUniversities(refresh: true);
                  }
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.universities.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No universities found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a country name and search for universities',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Header for results
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child:
                  state.country != null
                      ? RichText(
                        text: TextSpan(
                          text:
                              "Found ${state.universities.length} universities in ",
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: state.country ?? '',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Text(
                        'All Universities (${state.universities.length} loaded)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
            );
          }

          // Loading indicator for pagination
          if (index == state.universities.length + 1) {
            if (state.hasMoreData && state.country == null) {
              // Trigger load more when reaching the end
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!state.isLoading) {
                  ref.read(universityViewModelProvider.notifier).loadNextPage();
                }
              });

              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return null;
          }

          // University card
          final universityIndex = index - 1;
          if (universityIndex < state.universities.length) {
            final university = state.universities[universityIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: UniversityCard(
                university: university,
                onTap: () {
                  context.pushNamed(
                    'university_detail',
                    pathParameters: {'name': university.name},
                  );
                },
                onWebsiteTap: () {
                  if (university.website != null) {
                    _openWebsite(university.website!);
                  }
                },
              ),
            );
          }

          return null;
        },
        childCount:
            state.universities.length +
            (state.hasMoreData && state.country == null ? 2 : 1),
      ),
    );
  }
}
