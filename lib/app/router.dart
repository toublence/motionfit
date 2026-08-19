import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/challenges/application/challenge_controller.dart';
import 'package:motionfit_squat/features/challenges/presentation/challenge_screen.dart';
import 'package:motionfit_squat/features/exercise/presentation/exercise_challenge_screen.dart';
import 'package:motionfit_squat/features/exercise/presentation/exercise_home_screen.dart';
import 'package:motionfit_squat/features/plank/challenges/presentation/challenge_screen.dart'
    as plank_challenges;
import 'package:motionfit_squat/features/plank/challenges/application/challenge_controller.dart'
    as plank_challenge_state;
import 'package:motionfit_squat/features/plank/records/presentation/workout_session_detail_screen.dart'
    as plank_records;
import 'package:motionfit_squat/features/plank/workout/workout_routes.dart'
    as plank_workout;
import 'package:motionfit_squat/features/pushup/challenges/presentation/challenge_screen.dart'
    as pushup_challenges;
import 'package:motionfit_squat/features/pushup/challenges/application/challenge_controller.dart'
    as pushup_challenge_state;
import 'package:motionfit_squat/features/pushup/records/presentation/workout_session_detail_screen.dart'
    as pushup_records;
import 'package:motionfit_squat/features/pushup/workout_routes.dart'
    as pushup_workout;
import 'package:motionfit_squat/features/records/presentation/records_screen.dart';
import 'package:motionfit_squat/features/records/presentation/workout_session_detail_screen.dart';
import 'package:motionfit_squat/features/onboarding/presentation/onboarding_screen.dart';
import 'package:motionfit_squat/features/settings/presentation/settings_screen.dart';
import 'package:motionfit_squat/features/squat/application/workout_preparation.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_plan.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/active_workout_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/camera_guide_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/camera_permission_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/rest_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/rep_review_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/rep_timeline_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/workout_countdown_screen.dart';
import 'package:motionfit_squat/features/squat/presentation/screens/workout_summary_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final squatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'squat');
final challengeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'challenge',
);
final recordsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'records');
final settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

GoRouter createAppRouter({required bool onboardingCompleted}) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: onboardingCompleted ? '/squat' : '/onboarding',
  routes: [
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _AppNavigationShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: squatNavigatorKey,
          routes: [
            GoRoute(
              path: '/squat',
              builder: (context, state) => const ExerciseHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: challengeNavigatorKey,
          routes: [
            GoRoute(
              path: '/challenge',
              builder: (context, state) => const ExerciseChallengeScreen(),
              routes: [
                GoRoute(
                  path: 'pushup/:id',
                  builder: (context, state) =>
                      pushup_challenges.ChallengeDetailScreen(
                        challengeId: state.pathParameters['id']!,
                      ),
                ),
                GoRoute(
                  path: 'plank/:id',
                  builder: (context, state) =>
                      plank_challenges.ChallengeDetailScreen(
                        challengeId: state.pathParameters['id']!,
                      ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ChallengeDetailScreen(
                    challengeId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: recordsNavigatorKey,
          routes: [
            GoRoute(
              path: '/records',
              builder: (context, state) => const RecordsScreen(),
              routes: [
                GoRoute(
                  path: 'pushup/session/:sessionId',
                  builder: (context, state) =>
                      pushup_records.WorkoutSessionDetailScreen(
                        sessionId: state.pathParameters['sessionId']!,
                      ),
                ),
                GoRoute(
                  path: 'plank/session/:sessionId',
                  builder: (context, state) =>
                      plank_records.WorkoutSessionDetailScreen(
                        sessionId: state.pathParameters['sessionId']!,
                      ),
                ),
                GoRoute(
                  path: 'session/:sessionId',
                  builder: (context, state) => WorkoutSessionDetailScreen(
                    sessionId: state.pathParameters['sessionId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/rep-timeline/:sessionId',
      builder: (context, state) =>
          RepTimelineScreen(sessionId: state.pathParameters['sessionId']!),
      routes: [
        GoRoute(
          path: 'rep/:repNumber',
          builder: (context, state) => RepReviewScreen(
            sessionId: state.pathParameters['sessionId']!,
            repNumber: int.parse(state.pathParameters['repNumber']!),
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/pushup/rep-timeline/:sessionId',
      builder: (context, state) => pushup_workout.RepTimelineScreen(
        sessionId: state.pathParameters['sessionId']!,
      ),
      routes: [
        GoRoute(
          path: 'rep/:repNumber',
          builder: (context, state) => pushup_workout.RepReviewScreen(
            sessionId: state.pathParameters['sessionId']!,
            repNumber: int.parse(state.pathParameters['repNumber']!),
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/plank/hold-timeline/:sessionId',
      builder: (context, state) => plank_workout.RepTimelineScreen(
        sessionId: state.pathParameters['sessionId']!,
      ),
      routes: [
        GoRoute(
          path: 'second/:repNumber',
          builder: (context, state) => plank_workout.RepReviewScreen(
            sessionId: state.pathParameters['sessionId']!,
            repNumber: int.parse(state.pathParameters['repNumber']!),
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/prepare/permission',
      builder: (context, state) =>
          CameraPermissionScreen(preparation: _preparation(state.extra)),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/prepare/guide',
      builder: (context, state) =>
          CameraGuideScreen(preparation: _preparation(state.extra)),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/prepare/countdown',
      builder: (context, state) =>
          WorkoutCountdownScreen(preparation: _preparation(state.extra)),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/workout',
      builder: (context, state) => const ActiveWorkoutScreen(),
      routes: [
        GoRoute(path: 'rest', builder: (context, state) => const RestScreen()),
        GoRoute(
          path: 'summary',
          builder: (context, state) => const WorkoutSummaryScreen(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/pushup/prepare/permission',
      builder: (context, state) => pushup_workout.CameraPermissionScreen(
        preparation: _pushupPreparation(state.extra),
      ),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/pushup/prepare/guide',
      builder: (context, state) => pushup_workout.CameraGuideScreen(
        preparation: _pushupPreparation(state.extra),
      ),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/pushup/prepare/countdown',
      builder: (context, state) => pushup_workout.WorkoutCountdownScreen(
        preparation: _pushupPreparation(state.extra),
      ),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/pushup/workout',
      builder: (context, state) => const pushup_workout.ActiveWorkoutScreen(),
      routes: [
        GoRoute(
          path: 'rest',
          builder: (context, state) => const pushup_workout.RestScreen(),
        ),
        GoRoute(
          path: 'summary',
          builder: (context, state) =>
              const pushup_workout.WorkoutSummaryScreen(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/plank/prepare/permission',
      builder: (context, state) => plank_workout.CameraPermissionScreen(
        preparation: _plankPreparation(state.extra),
      ),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/plank/prepare/guide',
      builder: (context, state) => plank_workout.CameraGuideScreen(
        preparation: _plankPreparation(state.extra),
      ),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/plank/prepare/countdown',
      builder: (context, state) => plank_workout.WorkoutCountdownScreen(
        preparation: _plankPreparation(state.extra),
      ),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/plank/workout',
      builder: (context, state) => const plank_workout.ActiveWorkoutScreen(),
      routes: [
        GoRoute(
          path: 'rest',
          builder: (context, state) => const plank_workout.RestScreen(),
        ),
        GoRoute(
          path: 'summary',
          builder: (context, state) =>
              const plank_workout.WorkoutSummaryScreen(),
        ),
      ],
    ),
  ],
);

WorkoutPreparation _preparation(Object? extra) => switch (extra) {
  final WorkoutPreparation value => value,
  final WorkoutPlan value => WorkoutPreparation.newWorkout(value),
  _ => WorkoutPreparation.newWorkout(WorkoutPlan.defaults()),
};

pushup_workout.WorkoutPreparation _pushupPreparation(Object? extra) =>
    switch (extra) {
      final pushup_workout.WorkoutPreparation value => value,
      final pushup_workout.WorkoutPlan value =>
        pushup_workout.WorkoutPreparation.newWorkout(value),
      _ => pushup_workout.WorkoutPreparation.newWorkout(
        pushup_workout.WorkoutPlan.defaults(),
      ),
    };

plank_workout.WorkoutPreparation _plankPreparation(Object? extra) =>
    switch (extra) {
      final plank_workout.WorkoutPreparation value => value,
      final plank_workout.WorkoutPlan value =>
        plank_workout.WorkoutPreparation.newWorkout(value),
      _ => plank_workout.WorkoutPreparation.newWorkout(
        plank_workout.WorkoutPlan.defaults(),
      ),
    };

class _AppNavigationShell extends ConsumerWidget {
  const _AppNavigationShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final challengeBadge =
        (ref.watch(challengeBadgeProvider).value ?? false) ||
        (ref.watch(pushup_challenge_state.challengeBadgeProvider).value ??
            false) ||
        (ref.watch(plank_challenge_state.challengeBadgeProvider).value ??
            false);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: SafeArea(
          top: false,
          child: _CompactBottomNavigation(
            selectedIndex: navigationShell.currentIndex,
            onSelected: (index) {
              ref.read(analyticsServiceProvider).screenView(switch (index) {
                0 => 'workout_setup',
                1 => 'challenge',
                2 => 'records',
                _ => 'settings',
              });
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            items: [
              (
                icon: Icons.fitness_center_outlined,
                selectedIcon: Icons.fitness_center_rounded,
                label: l10n.navWorkout,
                showBadge: false,
              ),
              (
                icon: Icons.emoji_events_outlined,
                selectedIcon: Icons.emoji_events_rounded,
                label: l10n.navChallenge,
                showBadge: challengeBadge,
              ),
              (
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month_rounded,
                label: l10n.navRecords,
                showBadge: false,
              ),
              (
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: l10n.navSettings,
                showBadge: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _NavigationItem = ({
  IconData icon,
  IconData selectedIcon,
  String label,
  bool showBadge,
});

class _CompactBottomNavigation extends StatelessWidget {
  const _CompactBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<_NavigationItem> items;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .45),
          ),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Expanded(
            child: _NavigationButton(
              item: item,
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
          );
        }),
      ),
    ),
  );
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: 21,
                    color: color,
                  ),
                  if (item.showBadge)
                    PositionedDirectional(
                      top: -2,
                      end: -4,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                width: selected ? 18 : 0,
                height: 2,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
