enum MotionFitDisplayTheme { light, dark, system }

enum MotionFitColorTheme {
  byeokcheong,
  chuhyang,
  jangdan,
  cheonghyeon,
  haenghwang,
  chunyu,
  seolbaek,
  byeokja,
  chwiram,
}

T themePreferenceByName<T extends Enum>(
  Iterable<T> values,
  String? name,
  T fallback,
) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
