class Util {
  static String percentage(double? value, double? total) {
    return (((value ?? 0) / (total ?? 1)) * 100).toStringAsFixed(3) + "%";
  }

  static String moneyFormat(double? value) {
    double workingValue = value?.abs() ?? 0.0;
    String sign = (value ?? 0.0) < 0 ? "-" : "";

    //######.**
    String formattedValue = (workingValue).toStringAsFixed(2);
    if (workingValue < 1000) {
      // R ######.**
      return "R $sign${formattedValue}";
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
    //R ##'###.**
    return "R $sign${result.reversed.join()}.${parts.last}";
  }
}
