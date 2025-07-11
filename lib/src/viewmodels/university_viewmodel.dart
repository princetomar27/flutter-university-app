import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/university.dart';
import '../services/university_api_service.dart';

class UniversityViewModel extends StateNotifier<UniversityState> {
  final UniversityApiService _apiService;

  UniversityViewModel(this._apiService) : super(UniversityState.initial());

  Future<void> searchUniversities(String country) async {
    if (country.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please enter a country name',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      country: country,
      currentPage: 1,
    );

    try {
      final universities = await _apiService.searchUniversitiesByCountry(
        country,
      );
      state = state.copyWith(
        isLoading: false,
        universities: universities,
        error: null,
        country: country,
        hasMoreData: false, // No pagination for country search
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAllUniversities({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        universities: [],
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final allUniversities = await _apiService.getAllUniversities();
      final startIndex = (state.currentPage - 1) * state.pageSize;
      final endIndex = startIndex + state.pageSize;
      final paginatedUniversities = allUniversities.sublist(
        startIndex,
        endIndex > allUniversities.length ? allUniversities.length : endIndex,
      );

      state = state.copyWith(
        isLoading: false,
        universities:
            refresh
                ? paginatedUniversities
                : [...state.universities, ...paginatedUniversities],
        error: null,
        country: null,
        hasMoreData: endIndex < allUniversities.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (!state.hasMoreData || state.isLoading) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadAllUniversities();
  }

  void clearSearch() {
    state = UniversityState.initial();
    loadAllUniversities(refresh: true);
  }
}

class UniversityState {
  final List<University> universities;
  final bool isLoading;
  final String? error;
  final String? country;
  final int currentPage;
  final int pageSize;
  final bool hasMoreData;

  UniversityState({
    required this.universities,
    required this.isLoading,
    this.error,
    this.country,
    this.currentPage = 1,
    this.pageSize = 20,
    this.hasMoreData = true,
  });

  factory UniversityState.initial() {
    return UniversityState(
      universities: [],
      isLoading: false,
      error: null,
      country: null,
      currentPage: 1,
      pageSize: 20,
      hasMoreData: true,
    );
  }

  UniversityState copyWith({
    List<University>? universities,
    bool? isLoading,
    String? error,
    String? country,
    int? currentPage,
    int? pageSize,
    bool? hasMoreData,
  }) {
    return UniversityState(
      universities: universities ?? this.universities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      country: country,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}
