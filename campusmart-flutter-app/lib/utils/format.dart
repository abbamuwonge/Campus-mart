/// "UGX 650,000", the same format the prototype shows.
String cash(num amount) {
  final digits = amount.round().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return 'UGX $out';
}

/// "Yusuf Kamara" -> "YK" (two letters at most), as in the prototype's avatar.
String initials(String name) {
  final letters = name.split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).join();
  final two = letters.length > 2 ? letters.substring(0, 2) : letters;
  return two.toUpperCase();
}

String firstName(String name) {
  final parts = name.trim().split(' ');
  return parts.isEmpty ? name : parts.first;
}

String capitalize(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
