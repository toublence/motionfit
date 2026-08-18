class ReminderSchedule {
  const ReminderSchedule({
    required this.id,
    required this.weekday,
    required this.enabled,
    required this.hour,
    required this.minute,
  }) : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday),
       assert(hour >= 0 && hour <= 23),
       assert(minute >= 0 && minute <= 59);

  final int id;
  final int weekday;
  final bool enabled;
  final int hour;
  final int minute;

  ReminderSchedule copyWith({bool? enabled, int? hour, int? minute}) {
    return ReminderSchedule(
      id: id,
      weekday: weekday,
      enabled: enabled ?? this.enabled,
      hour: (hour ?? this.hour).clamp(0, 23).toInt(),
      minute: (minute ?? this.minute).clamp(0, 59).toInt(),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'weekday': weekday,
    'enabled': enabled ? 1 : 0,
    'hour': hour,
    'minute': minute,
  };

  factory ReminderSchedule.fromMap(Map<String, Object?> map) =>
      ReminderSchedule(
        id: map['id']! as int,
        weekday: map['weekday']! as int,
        enabled: map['enabled'] == 1,
        hour: map['hour']! as int,
        minute: map['minute']! as int,
      );

  static List<ReminderSchedule> defaults() => List.generate(
    7,
    (index) => ReminderSchedule(
      id: index + 1,
      weekday: index + 1,
      enabled: false,
      hour: 19,
      minute: 0,
    ),
    growable: false,
  );
}
