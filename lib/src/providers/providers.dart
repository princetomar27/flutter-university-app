import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/university_api_service.dart';
import '../viewmodels/university_viewmodel.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import '../models/user_profile.dart';

// Service Providers
final universityApiServiceProvider = Provider<UniversityApiService>((ref) {
  return UniversityApiService();
});

// ViewModel Providers
final universityViewModelProvider =
    StateNotifierProvider<UniversityViewModel, UniversityState>((ref) {
      final apiService = ref.watch(universityApiServiceProvider);
      return UniversityViewModel(apiService);
    });

final userProfileViewModelProvider =
    StateNotifierProvider<UserProfileViewModel, UserProfile>((ref) {
      return UserProfileViewModel();
    });
