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

    state = state.copyWith(isLoading: true, error: null, country: country);

    try {
      final universities = await _apiService.searchUniversitiesByCountry(
        country,
      );
      state = state.copyWith(
        isLoading: false,
        universities: universities,
        error: null,
        country: country,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearSearch() {
    state = UniversityState.initial();
  }
}

class UniversityState {
  final List<University> universities;
  final bool isLoading;
  final String? error;
  final String? country;

  UniversityState({
    required this.universities,
    required this.isLoading,
    this.error,
    this.country,
  });

  factory UniversityState.initial() {
    return UniversityState(
      universities: [],
      isLoading: false,
      error: null,
      country: null,
    );
  }

  UniversityState copyWith({
    List<University>? universities,
    bool? isLoading,
    String? error,
    String? country,
  }) {
    return UniversityState(
      universities: universities ?? this.universities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      country: country,
    );
  }
}
