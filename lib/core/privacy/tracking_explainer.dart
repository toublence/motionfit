import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';

/// An explanation only. Continue is not ATT permission or UMP consent.
Future<bool> showTrackingExplainer(BuildContext context) async {
  final locale = Localizations.localeOf(context);
  final language =
      locale.languageCode == 'zh' &&
          (locale.scriptCode == 'Hant' ||
              const ['TW', 'HK', 'MO'].contains(locale.countryCode))
      ? 'zh_Hant'
      : locale.languageCode;
  final copy = _copy[language] ?? _copy['en']!;
  final navigator = Navigator.of(context, rootNavigator: true);
  final route = DialogRoute<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(copy.$1),
        content: SingleChildScrollView(
          child: Text(copy.$2, style: const TextStyle(height: 1.5)),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('tracking_explainer_continue'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppLocalizations.of(dialogContext).commonContinue),
            ),
          ),
        ],
      ),
    ),
  );
  final acknowledged = await navigator.push(route);
  // Unlike push()'s result, completed waits for the dialog overlay to leave.
  // The native ATT prompt must not overlap the closing Flutter dialog.
  await route.completed;
  return acknowledged == true;
}

const _copy = <String, (String, String)>{
  'ko': (
    '광고로 무료 기능을 지원합니다',
    'MotionFit의 무료 기능은 광고로 지원됩니다.\n'
        '다음 화면에서 추적 허용 여부를 선택할 수 있습니다. 허용하면 다른 회사의 앱과 웹사이트에서 얻은 정보를 활용해 관심사에 맞는 광고를 제공하는 데 도움이 됩니다.\n\n'
        '추적을 허용하지 않아도 이용할 수 있는 기능은 동일합니다.',
  ),
  'en': (
    'Ads support free features',
    'Advertising supports MotionFit’s free features.\n'
        'On the next screen, you can choose whether to allow tracking. Allowing it helps provide relevant ads using information from other companies’ apps and websites.\n\n'
        'Your available features stay the same if you do not allow tracking.',
  ),
  'ja': (
    '広告が無料機能を支えています',
    'MotionFitの無料機能は広告によって支えられています。\n'
        '次の画面でトラッキングを許可するか選べます。許可すると、他社のアプリやウェブサイトの情報を利用し、関心に合った広告を表示するのに役立ちます。\n\n'
        '許可しなくても、利用できる機能は変わりません。',
  ),
  'de': (
    'Werbung unterstützt kostenlose Funktionen',
    'Werbung unterstützt die kostenlosen Funktionen von MotionFit.\n'
        'Auf dem nächsten Bildschirm kannst du Tracking erlauben oder ablehnen. Mit deiner Erlaubnis können Informationen aus Apps und Websites anderer Unternehmen für passendere Werbung genutzt werden.\n\n'
        'Auch ohne Erlaubnis bleiben dieselben Funktionen verfügbar.',
  ),
  'es': (
    'Los anuncios apoyan las funciones gratuitas',
    'La publicidad apoya las funciones gratuitas de MotionFit.\n'
        'En la siguiente pantalla puedes permitir o rechazar el seguimiento. Permitirlo ayuda a mostrar anuncios relevantes usando información de apps y sitios web de otras empresas.\n\n'
        'Si no lo permites, tendrás las mismas funciones disponibles.',
  ),
  'fr': (
    'La publicité soutient les fonctions gratuites',
    'La publicité soutient les fonctions gratuites de MotionFit.\n'
        'Sur l’écran suivant, vous pouvez autoriser ou refuser le suivi. L’autoriser aide à proposer des annonces pertinentes à partir d’informations provenant d’apps et de sites web d’autres entreprises.\n\n'
        'Les mêmes fonctions restent disponibles si vous refusez le suivi.',
  ),
  'ar': (
    'الإعلانات تدعم الميزات المجانية',
    'تدعم الإعلانات ميزات MotionFit المجانية.\n'
        'في الشاشة التالية، يمكنك السماح بالتتبع أو رفضه. يساعد السماح به في عرض إعلانات ملائمة باستخدام معلومات من تطبيقات ومواقع شركات أخرى.\n\n'
        'تبقى الميزات المتاحة لك كما هي إذا لم تسمح بالتتبع.',
  ),
  'zh': (
    '广告支持免费功能',
    'MotionFit的免费功能由广告支持。\n'
        '在下一个页面，你可以选择是否允许跟踪。允许后，可以利用其他公司应用和网站的信息，帮助提供符合兴趣的广告。\n\n'
        '即使不允许跟踪，可使用的功能也不会改变。',
  ),
  'zh_Hant': (
    '廣告支持免費功能',
    'MotionFit的免費功能由廣告支持。\n'
        '在下一個畫面，你可以選擇是否允許追蹤。允許後，可以利用其他公司App和網站的資訊，協助提供符合興趣的廣告。\n\n'
        '即使不允許追蹤，可使用的功能也不會改變。',
  ),
};
