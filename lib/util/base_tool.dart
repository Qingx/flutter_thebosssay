class BaseTool {
  static bool eq(double num1, double num2) {
    return (num1 - num2).abs() <= 0.000005;
  }
}

