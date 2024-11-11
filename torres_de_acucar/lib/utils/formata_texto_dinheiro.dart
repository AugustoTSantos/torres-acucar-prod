import 'package:flutter/services.dart';

class FormataTextoDinheiro extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // nome em inglês por conta do TExtInputDormatter
    TextEditingValue newValue, // nome em inglês por conta do TExtInputDormatter
  ) {
    // Allow empty value
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only numbers and a single comma
    String novoItem = newValue.text.replaceAll(',', '.');
    if (double.tryParse(novoItem) == null) {
      return oldValue;
    }

    // Split the value by the comma
    List<String> parts = novoItem.split('.');
    if (parts.length > 2) {
      // More than one decimal point/comma
      return oldValue;
    }

    // Limit decimal places to 2 digits
    if (parts.length == 2 && parts[1].length > 2) {
      return oldValue;
    }

    return newValue;
  }
}
