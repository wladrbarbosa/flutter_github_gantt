class Configs {
  static late double perHourValue;
  static late Duration graphColumnsPeriod;
  static late List<DateTime> specificDatesOfNoWork;
  static late List<int> dayOfWeekOfNoWork;
  static late List<Map<String, int>> hourOfNoWork;

  static initializeConfigs() {
    graphColumnsPeriod = const Duration(minutes: 120);
    perHourValue = 20.0;
    specificDatesOfNoWork = [];
    dayOfWeekOfNoWork = [
      6
    ];
    hourOfNoWork = [
      {
        "inicio": 0,
        "fim": 2,
      },
      {
        "inicio": 2,
        "fim": 4,
      },
      {
        "inicio": 4,
        "fim": 6,
      },
      {
        "inicio": 6,
        "fim": 8,
      },
      {
        "inicio": 8,
        "fim": 10,
      },
      {
        "inicio": 10,
        "fim": 12,
      },
      {
        "inicio": 12,
        "fim": 14,
      },
      {
        "inicio": 14,
        "fim": 16,
      },
      {
        "inicio": 16,
        "fim": 18,
      },
    ];
  }
}