import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../features/astrology/presentation/pages/astrologer_details_page.dart';
import '../../features/astrology/presentation/pages/astrology_page.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/auth/presentation/pages/edit_profile_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/festival/presentation/pages/festival_details_page.dart';
import '../../features/home/data/models/location_model.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/home/presentation/pages/nearby_temples_page.dart';
import '../../features/hotel_details/presentation/pages/hotel_details_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/reels/presentation/pages/reels_page.dart';
import '../../features/temple_details/presentation/pages/temple_details_page.dart';
import '../../features/deity/presentation/pages/deity_list_page.dart';
import '../../features/deity/presentation/pages/deity_details_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'nearby-temples',
                    builder: (context, state) => const NearbyTemplesPage(),
                  ),
                  GoRoute(
                    path: 'temples/:id',
                    builder: (context, state) {
                      return TempleDetailsPage(
                        templeId: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'hotels/:id',
                    builder: (context, state) {
                      return HotelDetailsPage(
                        hotelId: state.pathParameters['id']!,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'festival-details',
                    builder: (context, state) {
                      final festival = state.extra as FestivalModel;
                      return FestivalDetailsPage(festival: festival);
                    },
                  ),
                  GoRoute(
                    path: 'deities',
                    builder: (context, state) => const DeityListPage(),
                    routes: [
                      GoRoute(
                        path: 'details',
                        builder: (context, state) {
                          final deity = state.extra as DeityModel;
                          return DeityDetailsPage(deity: deity);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/astrology',
                builder: (context, state) => const AstrologyPage(),
                routes: [
                  GoRoute(
                    path: 'details/:id',
                    builder: (context, state) {
                      return AstrologerDetailsPage(
                        id: state.pathParameters['id']!,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reels',
                builder: (context, state) => const ReelsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) {
                  return const FavoritesPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final routeUser = state.extra as UserModel?;
                      final currentUser = ref.read(userProvider).valueOrNull;
                      final user = routeUser ?? currentUser;

                      if (user == null) {
                        return const _SplashPage();
                      }

                      return EditProfilePage(user: user);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final onboardingHydrated = ref.read(onboardingHydratedProvider);
      final authHydrated = ref.read(authHydratedProvider);
      final onboardingCompleted = ref.read(onboardingProvider);
      final isLoggedIn = ref.read(authStateProvider);
      final userAsync = ref.read(userProvider);
      final location = state.matchedLocation;

      const authPaths = {'/login', '/signup'};
      final isAuthPath = authPaths.contains(location);
      final isOnboardingPath = location == '/onboarding';

      // 1. Check basic hydration first
      if (!onboardingHydrated || !authHydrated) {
        return location == '/splash' ? null : '/splash';
      }

      // 2. If onboarding not completed, go to onboarding (unless already there)
      if (!onboardingCompleted) {
        return isOnboardingPath ? null : '/onboarding';
      }

      // 3. Handle Authentication
      if (!isLoggedIn) {
        return isAuthPath ? null : '/login';
      }

      // 4. Verification Check: Profile Fetching
      // If we are logged in but profile is still loading, stay on splash.
      // We explicitly check .isLoading and ONLY treat it as settled when loading finishes.
      if (userAsync.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final user = userAsync.valueOrNull;
      // If profile fetch finished but returned null, user must re-login.
      if (user == null || user.id.isEmpty) {
        return isAuthPath ? null : '/login';
      }

      // 5. Success: Redirect from Loading/Auth paths to Home.
      if (location == '/splash' || isAuthPath || isOnboardingPath) {
        return '/home';
      }

      return null;
    },
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<bool>(onboardingHydratedProvider, (_, __) => notifyListeners());
    ref.listen<bool>(authHydratedProvider, (_, __) => notifyListeners());
    ref.listen<bool>(onboardingProvider, (_, __) => notifyListeners());
    ref.listen<bool>(authStateProvider, (_, __) => notifyListeners());
    ref.listen<AsyncValue<UserModel?>>(userProvider, (_, __) {
      notifyListeners();
    });
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6831),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 140.w,
              height: 140.w,
            ),
          ],
        ),
      ),
    );
  }
}
