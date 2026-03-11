import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';

import 'features/home/presentation/pages/main_shell.dart';
import 'features/auth/presentation/providers/auth_state_provider.dart';
import 'features/auth/presentation/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Notifications
  await NotificationService.initialize();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ml')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MandirMapApp(),
      ),
    ),
  );
}

class MandirMapApp extends ConsumerWidget {
  const MandirMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingProvider);
    final isLoggedIn = ref.watch(authStateProvider);
    final userAsync = ref.watch(userProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        print(
          '[App] Rebuilding with isLoggedIn: $isLoggedIn, onboarding: $onboardingCompleted',
        );

        Widget homeWidget;
        if (!onboardingCompleted) {
          homeWidget = const OnboardingPage();
        } else if (!isLoggedIn) {
          homeWidget = const LoginPage();
        } else {
          // If logged in according to state flag, verify we can get the profile
          homeWidget = userAsync.when(
            data: (user) {
              if (user == null || user.id.isEmpty) {
                return const LoginPage();
              }
              return const MainShell();
            },
            loading:
                () => Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: const CircularProgressIndicator(
                            color: Color(0xFFFB6D3B),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Getting your profile...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            error: (err, _) => const LoginPage(),
          );
        }

        return MaterialApp(
          key: ValueKey('mm-app-$isLoggedIn-$onboardingCompleted'),
          title: 'app_name'.tr(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: homeWidget,
        );
      },
    );
  }
}
