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

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        Widget homeWidget;
        if (!onboardingCompleted) {
          homeWidget = const OnboardingPage();
        } else if (!isLoggedIn) {
          homeWidget = const LoginPage();
        } else {
          homeWidget = const MainShell();
        }

        return MaterialApp(
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
