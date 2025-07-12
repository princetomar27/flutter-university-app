import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertask/src/widgets/univeristy_list_widget.dart';
import 'package:fluttertask/src/widgets/university_search_section_widget.dart';
import '../providers/providers.dart';
import '../widgets/user_profile_card.dart';
import '../viewmodels/university_viewmodel.dart';

enum _HeaderState { loading, error, empty, data }

enum _PaginationState { loading, loadMore, end, none }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(universityViewModelProvider.notifier)
          .loadAllUniversities(refresh: true);
    });
  }

  void _searchUniversities() {
    ref.read(universityViewModelProvider.notifier).performSearch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final userProfile = ref.watch(userProfileViewModelProvider);
    final universityState = ref.watch(universityViewModelProvider);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          controller:
              ref.read(universityViewModelProvider.notifier).scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              title: const Text('Global University Search'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              elevation: 2,
              floating: true,
              snap: true,
              pinned: false,
            ),

            // User Profile and Search Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // User Profile Card
                    UserProfileCard(userProfile: userProfile),
                    const SizedBox(height: 24),

                    // Search Section
                    RepaintBoundary(
                      child: UniversitySearchSection(
                        onSearch: _searchUniversities,
                        isLoading: universityState.isLoading,
                        key: const ValueKey('university_search_section'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Results Header
            _buildResultsHeader(universityState),

            // Universities List using SliverList.builder for optimal performance
            UniversitiesListWidget(universities: universityState.universities),

            // Pagination Loading Indicator
            _buildPaginationLoader(universityState),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(UniversityState state) {
    // Determine UI state
    late final _HeaderState headerState;
    if (state.isLoading && state.universities.isEmpty) {
      headerState = _HeaderState.loading;
    } else if (state.error != null && state.universities.isEmpty) {
      headerState = _HeaderState.error;
    } else if (state.universities.isEmpty) {
      headerState = _HeaderState.empty;
    } else {
      headerState = _HeaderState.data;
    }

    switch (headerState) {
      case _HeaderState.loading:
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32.0),
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
          ),
        );
      case _HeaderState.error:
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
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
          ),
        );
      case _HeaderState.empty:
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No universities found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
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
          ),
        );
      case _HeaderState.data:
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      ref
                          .read(universityViewModelProvider.notifier)
                          .paginationInfo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                if (state.country == null && state.hasMoreData)
                  const SizedBox(height: 4),
                if (state.country == null && state.hasMoreData)
                  Text(
                    'Scroll down to load more universities',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                if (state.country != null && state.hasMoreData)
                  const SizedBox(height: 4),
                if (state.country != null && state.hasMoreData)
                  Text(
                    'Scroll down to load more universities in ${state.country}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildPaginationLoader(UniversityState state) {
    // Determine UI state
    late final _PaginationState paginationState;
    if (state.isLoadingNextPage) {
      paginationState = _PaginationState.loading;
    } else if (state.hasMoreData &&
        state.universities.isNotEmpty &&
        !state.isLoading) {
      paginationState = _PaginationState.loadMore;
    } else if (!state.hasMoreData && state.universities.isNotEmpty) {
      paginationState = _PaginationState.end;
    } else {
      paginationState = _PaginationState.none;
    }

    switch (paginationState) {
      case _PaginationState.loading:
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Loading more universities...'),
                ],
              ),
            ),
          ),
        );
      case _PaginationState.loadMore:
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (state.country != null) {
                    ref
                        .read(universityViewModelProvider.notifier)
                        .loadNextPageForCountry();
                  } else {
                    ref
                        .read(universityViewModelProvider.notifier)
                        .loadNextPage();
                  }
                },
                child: Text(
                  state.country != null
                      ? 'Load More Universities in ${state.country}'
                      : 'Load More Universities',
                ),
              ),
            ),
          ),
        );
      case _PaginationState.end:
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                state.country != null
                    ? 'All universities in ${state.country} loaded'
                    : 'All universities loaded',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ),
        );
      case _PaginationState.none:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }
}
