class Configs {
  static late Duration graphColumnsPeriod;

  static initializeConfigs() {
    graphColumnsPeriod = const Duration(minutes: 180);
  }
}