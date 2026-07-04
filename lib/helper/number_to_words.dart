String amountInWords(num amount) {
  if (amount < 0) {
    return "Negative ${amountInWords(-amount)}";
  }

  List<String> parts = amount.toStringAsFixed(2).split('.');
  int rupees = int.parse(parts[0]);
  int paise = int.parse(parts[1]);

  String rupeeText = rupees == 0 ? "Zero" : _convertNumber(rupees);
  String paiseText = paise == 0 ? "" : _convertNumber(paise);
  String rupeeWord = rupees == 1 ? "Rupee" : "Rupees";

  if (rupees == 0 && paise == 0) {
    return "Zero Rupees Only";
  } else if (rupees > 0 && paise == 0) {
    return "$rupeeText $rupeeWord Only";
  } else if (rupees == 0 && paise > 0) {
    return "$paiseText Paise Only";
  } else {
    return "$rupeeText $rupeeWord and $paiseText Paise Only";
  }
}

String _convertNumber(int number) {
  if (number == 0) return "Zero";

  final List<String> ones = [
    "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
    "Seventeen", "Eighteen", "Nineteen"
  ];

  final List<String> tens = [
    "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
  ];

  String result = "";

  if (number >= 10000000) {
    result += "${_convertNumber(number ~/ 10000000)} Crore";
    number %= 10000000;
    if (number > 0) result += " ";
  }

  if (number >= 100000) {
    result += "${_convertNumber(number ~/ 100000)} Lakh";
    number %= 100000;
    if (number > 0) result += " ";
  }

  if (number >= 1000) {
    result += "${_convertNumber(number ~/ 1000)} Thousand";
    number %= 1000;
    if (number > 0) result += " ";
  }

  if (number >= 100) {
    result += "${ones[number ~/ 100]} Hundred";
    number %= 100;
    if (number > 0) result += " ";
  }

  if (number >= 20) {
    result += tens[number ~/ 10];
    number %= 10;
    if (number > 0) result += " ${ones[number]}";
  } else if (number > 0) {
    result += ones[number];
  }

  return result.trim();
}