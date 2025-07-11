import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

class UserProfileViewModel extends StateNotifier<UserProfile> {
  UserProfileViewModel() : super(UserProfile.mock());

  void updateProfile(UserProfile newProfile) {
    state = newProfile;
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }
}

extension UserProfileExtension on UserProfile {
  UserProfile copyWith({String? name, String? email, String? avatarUrl}) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
