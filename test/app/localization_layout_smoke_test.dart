import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_theme.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';

void main() {
  test('ships exactly the nine required locales', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.toLanguageTag()),
      unorderedEquals([
        'en',
        'ko',
        'de',
        'es',
        'fr',
        'ja',
        'ar',
        'zh',
        'zh-Hant',
      ]),
    );
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      '${locale.languageCode} localization loads with directionality',
      (tester) async {
        late TextDirection direction;
        late String appName;

        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                direction = Directionality.of(context);
                appName = AppLocalizations.of(context).appName;
                return Scaffold(body: Text(appName));
              },
            ),
          ),
        );

        expect(appName.trim(), isNotEmpty);
        expect(find.text(appName), findsOneWidget);
        expect(
          direction,
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'small screen with 200% text remains scrollable without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          theme: MotionFitTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: SafeArea(
              child: ResponsivePage(
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return ListView(
                      children: [
                        Text(
                          l10n.appName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.guideSubtitle),
                        const SizedBox(height: 16),
                        Text(l10n.privacyStoredDataDescription),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
