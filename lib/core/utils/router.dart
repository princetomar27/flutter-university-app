import 'package:go_router/go_router.dart';
import '../../src/views/home_screen.dart';
import '../../src/views/university_detail_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/university/:name',
      name: 'university_detail',
      builder: (context, state) {
        final universityName = state.pathParameters['name'] ?? '';
        return UniversityDetailScreen(universityName: universityName);
      },
    ),
  ],
);
