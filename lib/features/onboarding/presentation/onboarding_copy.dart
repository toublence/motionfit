import 'package:flutter/widgets.dart';

// Copy ported from projects/android/motionfit/res/values*/onboarding.xml.
class OnboardingCopy {
  const OnboardingCopy(this.language);
  factory OnboardingCopy.forLocale(Locale locale) => OnboardingCopy(
    locale.languageCode == 'zh' &&
            (locale.scriptCode == 'Hant' ||
                const ['TW', 'HK', 'MO'].contains(locale.countryCode))
        ? 'zh_Hant'
        : locale.languageCode,
  );
  final String language;
  String operator [](String key) =>
      _translations[language]?[key] ?? _translations['en']![key]!;
}

const _translations = <String, Map<String, String>>{
  "en": {
    "instruction_move_back": "Move back a little",
    "speak_ready": "Ready",
    "metric_depth": "Depth",
    "metric_knee_stability": "Knee stability",
    "metric_tempo": "Tempo",
    "form_score_label": "FORM SCORE",
    "onboarding_measure_heading":
        "What matters is not just\nthat you exercised,\nbut how much you improved.",
    "onboarding_improve_heading": "Measure.\nChange one thing.\nCheck again.",
    "onboarding_try_heading": "See it for yourself.",
    "onboarding_try_body": "Three squats are enough.",
    "onboarding_skip": "Skip",
    "onboarding_next": "Next",
    "onboarding_start": "Start first measurement",
    "onboarding_correction": "Guide your knees a little outward",
    "onboarding_demo": "Measurement example",
    "onboarding_measure_description":
        "Measurement example: pose landmarks and the counter track three squats. After completion: Form Score 61, depth 72, knee stability 54 and tempo 58.",
    "onboarding_improve_description":
        "Correction example: a squat reveals knee stability 54. After feedback and two more squats, knee stability changes from 54 to 66 and Form Score from 61 to 69.",
    "onboarding_try_description":
        "Camera setup example: a person steps back into the frame. Ready, then a 3, 2, 1 countdown, followed by one squat.",
    "onboarding_rep_label": "REP",
  },
  "ko": {
    "instruction_move_back": "조금만 뒤로 이동하세요",
    "speak_ready": "준비",
    "metric_depth": "깊이",
    "metric_knee_stability": "무릎 안정성",
    "metric_tempo": "템포",
    "form_score_label": "폼 스코어",
    "onboarding_measure_heading": "운동을 했다는 것보다\n얼마나 좋아졌는지가 중요하니까.",
    "onboarding_improve_heading": "측정하고,\n하나를 고치고,\n다시 확인하세요.",
    "onboarding_try_heading": "직접 확인해보세요.",
    "onboarding_try_body": "스쿼트 3번이면 충분합니다.",
    "onboarding_skip": "건너뛰기",
    "onboarding_next": "다음",
    "onboarding_start": "첫 측정 시작",
    "onboarding_correction": "무릎을 조금 바깥으로",
    "onboarding_demo": "측정 예시",
    "onboarding_measure_description":
        "측정 예시: 스쿼트 3회에 맞춰 횟수가 증가하고 관절선이 움직입니다. 완료 후 폼 스코어 61, 깊이 72, 무릎 안정성 54, 템포 58이 나타납니다.",
    "onboarding_improve_description":
        "교정 예시: 스쿼트 후 무릎 안정성 54를 확인합니다. 무릎을 바깥으로 고쳐 다시 2회 수행하면 무릎 안정성이 54에서 66, 폼 스코어가 61에서 69로 바뀝니다.",
    "onboarding_try_description":
        "카메라 준비 예시: 가까이 서 있던 사람이 한 걸음 뒤로 이동해 프레임 안에 들어옵니다. 준비 안내와 3, 2, 1 카운트다운 후 스쿼트를 1회 수행합니다.",
    "onboarding_rep_label": "횟수",
  },
  "ja": {
    "instruction_move_back": "少し下がってください",
    "speak_ready": "準備",
    "metric_depth": "深さ",
    "metric_knee_stability": "ひざの安定性",
    "metric_tempo": "テンポ",
    "form_score_label": "フォームスコア",
    "onboarding_measure_heading": "運動したことより、\nどれだけ上達したかが\n大切だから。",
    "onboarding_improve_heading": "測定して、\nひとつ直して、\nもう一度確かめましょう。",
    "onboarding_try_heading": "自分で確かめましょう。",
    "onboarding_try_body": "スクワット3回で十分です。",
    "onboarding_skip": "スキップ",
    "onboarding_next": "次へ",
    "onboarding_start": "初めての測定を開始",
    "onboarding_correction": "膝を少し外側へ",
    "onboarding_demo": "測定の例",
    "onboarding_measure_description":
        "スクワットする人の動きに関節の線が重なります。フォームスコア61と深さ、膝の安定性、テンポの測定例です。",
    "onboarding_improve_description":
        "測定例：膝の安定性54。修正後に膝が外側へ動き、フォームスコアが61から69へ変わります。",
    "onboarding_try_description": "スマートフォンの前でスクワットする人の動きに関節の線が重なります。",
    "onboarding_rep_label": "回数",
  },
  "de": {
    "instruction_move_back": "Geh ein Stück zurück",
    "speak_ready": "Bereit",
    "metric_depth": "Tiefe",
    "metric_knee_stability": "Kniestabilität",
    "metric_tempo": "Tempo",
    "form_score_label": "TECHNIKWERT",
    "onboarding_measure_heading":
        "Es zählt nicht nur,\ndass du trainiert hast,\nsondern wie du dich verbesserst.",
    "onboarding_improve_heading": "Messen.\nEine Sache ändern.\nErneut prüfen.",
    "onboarding_try_heading": "Erlebe es selbst.",
    "onboarding_try_body": "Drei Kniebeugen reichen.",
    "onboarding_skip": "Überspringen",
    "onboarding_next": "Weiter",
    "onboarding_start": "Erste Messung starten",
    "onboarding_correction": "Führe die Knie etwas nach außen",
    "onboarding_demo": "Messbeispiel",
    "onboarding_measure_description":
        "Eine Person macht Kniebeugen, während Gelenkpunkte erscheinen. Beispiel: Technikwert 61 mit Tiefe, Kniestabilität und Tempo.",
    "onboarding_improve_description":
        "Beispiel: Kniestabilität 54. Nach einer Korrektur bewegen sich die Knie nach außen und der Technikwert steigt von 61 auf 69.",
    "onboarding_try_description":
        "Ein Smartphone zeigt eine Person bei einer Kniebeuge mit Gelenkpunkten, die ihrer Bewegung folgen.",
    "onboarding_rep_label": "WDH.",
  },
  "es": {
    "instruction_move_back": "Retrocede un poco",
    "speak_ready": "Listo",
    "metric_depth": "Profundidad",
    "metric_knee_stability": "Estabilidad de rodillas",
    "metric_tempo": "Ritmo",
    "form_score_label": "PUNTUACIÓN DE TÉCNICA",
    "onboarding_measure_heading":
        "No solo importa entrenar,\nsino cuánto mejoras.",
    "onboarding_improve_heading":
        "Mide.\nCorrige una cosa.\nComprueba de nuevo.",
    "onboarding_try_heading": "Compruébalo tú mismo.",
    "onboarding_try_body": "Bastan tres sentadillas.",
    "onboarding_skip": "Omitir",
    "onboarding_next": "Siguiente",
    "onboarding_start": "Iniciar primera medición",
    "onboarding_correction": "Lleva las rodillas un poco hacia fuera",
    "onboarding_demo": "Ejemplo de medición",
    "onboarding_measure_description":
        "Una persona hace sentadillas mientras aparecen puntos articulares. Ejemplo: puntuación de técnica 61 con profundidad, estabilidad de rodillas y ritmo.",
    "onboarding_improve_description":
        "Ejemplo: estabilidad de rodillas 54. Tras corregir las rodillas hacia fuera, puntuación de técnica cambia de 61 a 69.",
    "onboarding_try_description":
        "Un teléfono muestra a una persona haciendo una sentadilla, con puntos articulares alineados con su movimiento.",
    "onboarding_rep_label": "REPETICIONES",
  },
  "fr": {
    "instruction_move_back": "Reculez un peu",
    "speak_ready": "Prêt",
    "metric_depth": "Profondeur",
    "metric_knee_stability": "Stabilité des genoux",
    "metric_tempo": "Tempo",
    "form_score_label": "SCORE DE TECHNIQUE",
    "onboarding_measure_heading":
        "Ce qui compte,\nce sont vos progrès,\npas seulement vos séances.",
    "onboarding_improve_heading":
        "Mesurez.\nCorrigez un point.\nVérifiez à nouveau.",
    "onboarding_try_heading": "Voyez par vous-même.",
    "onboarding_try_body": "Trois squats suffisent.",
    "onboarding_skip": "Passer",
    "onboarding_next": "Suivant",
    "onboarding_start": "Lancer la première mesure",
    "onboarding_correction": "Orientez les genoux un peu vers l’extérieur",
    "onboarding_demo": "Exemple de mesure",
    "onboarding_measure_description":
        "Une personne fait des squats et des repères articulaires apparaissent. Exemple : score de technique 61, avec profondeur, stabilité des genoux et tempo.",
    "onboarding_improve_description":
        "Exemple : stabilité des genoux 54. Après correction, les genoux vont vers l’extérieur et score de technique passe de 61 à 69.",
    "onboarding_try_description":
        "Un téléphone fait face à une personne faisant un squat. Les repères articulaires suivent son mouvement.",
    "onboarding_rep_label": "RÉP.",
  },
  "ar": {
    "instruction_move_back": "تراجع قليلًا",
    "speak_ready": "استعد",
    "metric_depth": "العمق",
    "metric_knee_stability": "ثبات الركبتين",
    "metric_tempo": "الإيقاع",
    "form_score_label": "درجة الأداء",
    "onboarding_measure_heading": "المهم ليس مجرد التمرين،\nبل مقدار تحسّنك.",
    "onboarding_improve_heading":
        "قِس الحركة.\nصحّح شيئًا واحدًا.\nتحقّق مجددًا.",
    "onboarding_try_heading": "جرّب بنفسك.",
    "onboarding_try_body": "ثلاثة تمارين قرفصاء تكفي.",
    "onboarding_skip": "تخطّي",
    "onboarding_next": "التالي",
    "onboarding_start": "ابدأ القياس الأول",
    "onboarding_correction": "وجّه ركبتيك قليلًا إلى الخارج",
    "onboarding_demo": "مثال للقياس",
    "onboarding_measure_description":
        "شخص يؤدي القرفصاء وتظهر نقاط المفاصل. مثال لدرجة الأداء 61 مع العمق وثبات الركبتين والإيقاع.",
    "onboarding_improve_description":
        "مثال: ثبات الركبتين 54. بعد التصحيح تتحرك الركبتان للخارج وتتغير درجة الأداء من 61 إلى 69.",
    "onboarding_try_description":
        "هاتف أمام شخص يؤدي القرفصاء مع نقاط مفاصل تتبع حركته.",
    "onboarding_rep_label": "التكرار",
  },
  "zh": {
    "instruction_move_back": "稍微往后退",
    "speak_ready": "准备",
    "metric_depth": "深度",
    "metric_knee_stability": "膝盖稳定性",
    "metric_tempo": "节奏",
    "form_score_label": "动作评分",
    "onboarding_measure_heading": "重要的不只是运动了，\n而是进步了多少。",
    "onboarding_improve_heading": "测量，\n改进一点，\n再次确认。",
    "onboarding_try_heading": "亲自试试看。",
    "onboarding_try_body": "三个深蹲就够了。",
    "onboarding_skip": "跳过",
    "onboarding_next": "下一步",
    "onboarding_start": "开始首次测量",
    "onboarding_correction": "膝盖稍微向外",
    "onboarding_demo": "测量示例",
    "onboarding_measure_description": "人物深蹲时出现关节连线。动作评分61以及深度、膝部稳定性和节奏的测量示例。",
    "onboarding_improve_description": "示例：膝部稳定性54。纠正后膝盖向外移动，动作评分从61变为69。",
    "onboarding_try_description": "人物在手机前深蹲，关节连线与动作同步。",
    "onboarding_rep_label": "次数",
  },
  "zh_Hant": {
    "instruction_move_back": "稍微往後退",
    "speak_ready": "準備",
    "metric_depth": "深度",
    "metric_knee_stability": "膝蓋穩定度",
    "metric_tempo": "節奏",
    "form_score_label": "動作分數",
    "onboarding_measure_heading": "重要的不只是運動了，\n而是進步了多少。",
    "onboarding_improve_heading": "測量，\n改善一點，\n再次確認。",
    "onboarding_try_heading": "親自試試看。",
    "onboarding_try_body": "三個深蹲就夠了。",
    "onboarding_skip": "略過",
    "onboarding_next": "下一步",
    "onboarding_start": "開始首次測量",
    "onboarding_correction": "膝蓋稍微向外",
    "onboarding_demo": "測量範例",
    "onboarding_measure_description": "人物深蹲時出現關節連線。動作評分61以及深度、膝部穩定性和節奏的測量範例。",
    "onboarding_improve_description": "範例：膝部穩定性54。修正後膝蓋向外移動，動作評分從61變為69。",
    "onboarding_try_description": "人物在手機前深蹲，關節連線與動作同步。",
    "onboarding_rep_label": "次數",
  },
};
