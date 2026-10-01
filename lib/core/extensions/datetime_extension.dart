extension DateUtils on DateTime {
  static const int monday = 1;
  static const int tuesday = 2;
  static const int wednesday = 3;
  static const int thursday = 4;
  static const int friday = 5;
  static const int saturday = 6;
  static const int sunday = 7;
  static const int daysPerWeek = 7;

  static final List<String> sortedWeekDaysNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Firday',
    'Saturday',
    'Sunday',
  ];

  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool get isThisWeek {
    // Calculate when is the start of the current week
    final startWeekDatetime = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday + 1),
    );
    return DateTime(year, month, day).isAfter(
          DateTime(
            startWeekDatetime.year,
            startWeekDatetime.month,
            startWeekDatetime.day - 1,
          ),
        ) &&
        DateTime(year, month, day).isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1,
          ),
        );
  }

  bool get isThisMonth {
    final today = DateTime.now();
    return today.month == month && today.year == year;
  }

  bool get isThisYear {
    final today = DateTime.now();
    return today.year == year;
  }

  String get weekdayName {
    return sortedWeekDaysNames[weekday - 1];
  }
}

bool isSameDay(DateTime d1, DateTime d2) =>
    d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
