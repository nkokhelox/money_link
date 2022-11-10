class Util {
  static String percentage(double? value, double? total) {
    return (((value ?? 0) / (total ?? 1)) * 100).toStringAsFixed(3) + "%";
  }

  static String moneyFormat(double? value) {
    double workingValue = value ?? 0.0;
    //######.** or -######.**
    String formattedValue = (workingValue).toStringAsFixed(2);
    if (workingValue < 1000) {
      // R ######.** or R -######.**
      return "R ${formattedValue}";
    }
    //[######, **]
    List<String> parts = formattedValue.split('.');
    String bigAmount = parts.first;
    List<String> result = [];
    for (int i = bigAmount.length - 1, j = 1; i >= 0; i--, j++) {
      result.add(bigAmount[i]);
      if (j % 3 == 0 && i > 0) {
        result.add("'");
      }
    }
    return "R ${result.reversed.join()}.${parts.last}";
  }
}
