import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/university.dart';
import '../services/university_api_service.dart';
import 'dart:async';

// Optimized StateNotifier with proper pagination
class UniversityViewModel extends StateNotifier<UniversityState> {
  final UniversityApiService _apiService;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Debouncing for search
  Timer? _searchDebouncer;
  static const Duration _searchDebounceTime = Duration(milliseconds: 500);

  // Pagination constants
  static const int _pageSize = 20;
  static const double _scrollThreshold = 200.0;

  // Caching mechanism
  final Map<String, List<University>> _countrySearchCache = {};
  final Map<int, List<University>> _paginationCache = {};

  // Request cancellation
  Completer<void>? _currentRequest;

  // Pagination state
  bool _isLoadingNextPage = false;
  int _totalUniversitiesCount = 0;

  UniversityViewModel(this._apiService) : super(UniversityState.initial()) {
    _setupScrollListener();
    _setupSearchListener();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      // Check if we're near the bottom and conditions are met for pagination
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - _scrollThreshold) {
        _loadNextPageIfNeeded();
      }
    });
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      _onSearchTextChanged();
    });
  }

  void _onSearchTextChanged() {
    _searchDebouncer?.cancel();

    final query = searchController.text.trim();
    if (query.isEmpty) {
      // Do nothing on empty string
      return;
    }

    _searchDebouncer = Timer(_searchDebounceTime, () {
      searchUniversities(query);
    });
  }

  void _clearSearchAndLoadAll() {
    if (mounted) {
      state = state.copyWith(
        country: null,
        universities: [],
        currentPage: 1,
        hasMoreData: true,
        isLoadingNextPage: false,
      );
      loadAllUniversities(refresh: true);
    }
  }

  void _loadNextPageIfNeeded() {
    if (state.hasMoreData &&
        !state.isLoading &&
        !_isLoadingNextPage &&
        mounted) {
      if (state.country != null) {
        loadNextPageForCountry();
      } else {
        loadNextPage();
      }
    }
  }

  void _cancelCurrentRequest() {
    if (_currentRequest != null && !_currentRequest!.isCompleted) {
      _currentRequest!.complete();
      _currentRequest = null;
    }
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _cancelCurrentRequest();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> searchUniversities(String country) async {
    if (country.trim().isEmpty) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Please enter a country name',
        );
      }
      return;
    }

    final cacheKey = country.toLowerCase();

    // Check cache first
    if (_countrySearchCache.containsKey(cacheKey)) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          universities: _countrySearchCache[cacheKey]!,
          error: null,
          country: country,
          hasMoreData: false, // No pagination for cached results
          currentPage: 1,
          isLoadingNextPage: false,
        );
      }
      return;
    }

    _cancelCurrentRequest();
    _currentRequest = Completer<void>();

    if (mounted) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        country: country,
        currentPage: 1,
        universities: [],
        hasMoreData: true, // Enable pagination for country search
        isLoadingNextPage: false,
      );
    }

    try {
      // Get all universities for the country (simulating pagination)
      final allUniversities = await _apiService.searchUniversitiesByCountry(
        country,
      );

      if (_currentRequest?.isCompleted == true) {
        return;
      }

      // Cache the full result
      _countrySearchCache[cacheKey] = allUniversities;

      // Apply pagination
      final startIndex = 0;
      final endIndex = _pageSize;
      final paginatedUniversities = allUniversities.sublist(
        startIndex,
        endIndex > allUniversities.length ? allUniversities.length : endIndex,
      );

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          universities: paginatedUniversities,
          error: null,
          country: country,
          hasMoreData: endIndex < allUniversities.length,
          currentPage: 1,
          isLoadingNextPage: false,
        );
      }
    } catch (e) {
      if (mounted && _currentRequest?.isCompleted != true) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          isLoadingNextPage: false,
        );
      }
    } finally {
      _currentRequest?.complete();
      _currentRequest = null;
    }
  }

  Future<void> loadAllUniversities({bool refresh = false}) async {
    _cancelCurrentRequest();
    _currentRequest = Completer<void>();

    if (refresh) {
      _paginationCache.clear();
      _totalUniversitiesCount = 0;
      if (mounted) {
        state = state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          universities: [],
          country: null,
          hasMoreData: true,
          isLoadingNextPage: false,
        );
      }
    }

    try {
      List<University> newUniversities;

      // Check if we have this page cached
      if (_paginationCache.containsKey(state.currentPage)) {
        newUniversities = _paginationCache[state.currentPage]!;
      } else {
        // For demo purposes, we'll simulate pagination by getting all and slicing
        // In real app, you'd call paginated API endpoint
        final allUniversities = await _apiService.getAllUniversities();
        _totalUniversitiesCount = allUniversities.length;

        final startIndex = (state.currentPage - 1) * _pageSize;
        final endIndex = startIndex + _pageSize;

        newUniversities = allUniversities.sublist(
          startIndex,
          endIndex > allUniversities.length ? allUniversities.length : endIndex,
        );

        // Cache this page
        _paginationCache[state.currentPage] = newUniversities;
      }

      if (_currentRequest?.isCompleted == true) {
        return;
      }

      final hasMore = (state.currentPage * _pageSize) < _totalUniversitiesCount;

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          universities:
              refresh
                  ? newUniversities
                  : [...state.universities, ...newUniversities],
          error: null,
          country: null,
          hasMoreData: hasMore,
          isLoadingNextPage: false,
        );
      }
    } catch (e) {
      if (mounted && _currentRequest?.isCompleted != true) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          isLoadingNextPage: false,
        );
      }
    } finally {
      _currentRequest?.complete();
      _currentRequest = null;
      _isLoadingNextPage = false;
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasMoreData || _isLoadingNextPage || state.isLoading) return;

    _isLoadingNextPage = true;

    if (mounted) {
      state = state.copyWith(
        currentPage: state.currentPage + 1,
        isLoadingNextPage: true,
      );
    }

    await loadAllUniversities();
  }

  Future<void> loadNextPageForCountry() async {
    if (!state.hasMoreData ||
        _isLoadingNextPage ||
        state.isLoading ||
        state.country == null)
      return;

    _isLoadingNextPage = true;

    if (mounted) {
      state = state.copyWith(
        currentPage: state.currentPage + 1,
        isLoadingNextPage: true,
      );
    }

    try {
      final country = state.country!;
      final cacheKey = country.toLowerCase();

      if (!_countrySearchCache.containsKey(cacheKey)) {
        return;
      }

      final allUniversities = _countrySearchCache[cacheKey]!;
      final startIndex = (state.currentPage - 1) * _pageSize;
      final endIndex = startIndex + _pageSize;

      final newUniversities = allUniversities.sublist(
        startIndex,
        endIndex > allUniversities.length ? allUniversities.length : endIndex,
      );

      if (mounted) {
        state = state.copyWith(
          universities: [...state.universities, ...newUniversities],
          hasMoreData: endIndex < allUniversities.length,
          isLoadingNextPage: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoadingNextPage: false, error: e.toString());
      }
    } finally {
      _isLoadingNextPage = false;
    }
  }

  void clearSearch() {
    _searchDebouncer?.cancel();
    searchController.clear();
    _paginationCache.clear();

    if (mounted) {
      state = UniversityState.initial();
      loadAllUniversities(refresh: true);
    }
  }

  void performSearch() {
    final country = searchController.text.trim();
    if (country.isNotEmpty) {
      searchUniversities(country);
    }
  }

  void clearCache() {
    _countrySearchCache.clear();
    _paginationCache.clear();
  }

  Future<void> preloadCache() async {
    if (_paginationCache.isEmpty) {
      try {
        await loadAllUniversities(refresh: true);
      } catch (e) {
        debugPrint('Failed to preload cache: $e');
      }
    }
  }

  void clearAndReloadAll() {
    _searchDebouncer?.cancel();
    _clearSearchAndLoadAll();
  }

  // Getter for pagination info
  String get paginationInfo {
    if (state.country != null) {
      final cacheKey = state.country!.toLowerCase();
      final totalCount =
          _countrySearchCache[cacheKey]?.length ?? state.universities.length;
      return '${state.universities.length} of $totalCount universities in ${state.country}';
    }
    final loaded = state.universities.length;
    final total =
        _totalUniversitiesCount > 0 ? _totalUniversitiesCount : loaded;
    return '$loaded of $total universities loaded';
  }
}

// Enhanced State class with pagination support
@immutable
class UniversityState {
  final List<University> universities;
  final bool isLoading;
  final bool isLoadingNextPage;
  final String? error;
  final String? country;
  final int currentPage;
  final bool hasMoreData;

  const UniversityState({
    required this.universities,
    required this.isLoading,
    required this.isLoadingNextPage,
    this.error,
    this.country,
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  factory UniversityState.initial() {
    return const UniversityState(
      universities: [],
      isLoading: false,
      isLoadingNextPage: false,
      error: null,
      country: null,
      currentPage: 1,
      hasMoreData: true,
    );
  }

  UniversityState copyWith({
    List<University>? universities,
    bool? isLoading,
    bool? isLoadingNextPage,
    String? error,
    String? country,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return UniversityState(
      universities: universities ?? this.universities,
      isLoading: isLoading ?? this.isLoading,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      error: error,
      country: country,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UniversityState &&
        other.universities == universities &&
        other.isLoading == isLoading &&
        other.isLoadingNextPage == isLoadingNextPage &&
        other.error == error &&
        other.country == country &&
        other.currentPage == currentPage &&
        other.hasMoreData == hasMoreData;
  }

  @override
  int get hashCode {
    return Object.hash(
      universities,
      isLoading,
      isLoadingNextPage,
      error,
      country,
      currentPage,
      hasMoreData,
    );
  }
}
