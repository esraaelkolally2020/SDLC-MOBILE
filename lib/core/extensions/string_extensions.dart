extension StringValidation on String? {
  bool get isValidBaseUrl {
    if (this == null) {
      return false;
    } else {
      final uri = Uri.tryParse(this!);
      return uri != null &&
          uri.hasScheme &&
          uri.hasAuthority &&
          (uri.scheme.contains('https'));
    }
  }

  // bool get isNotEmptyOrNull => isNotEmpty;

  bool get isNull => this == null;

  bool get isEmptyOrNull => isNull || this!.trim().isEmpty;

  bool get isNotEmptyAndNotNull => !isEmptyOrNull;

  bool isHasArabicChar() {
    final RegExp englishAndNumberCharacters = RegExp(
      r"^[a-zA-Z-0-9-.-_.@.\s\']*$",
    );
    if (this != null && this!.isNotEmpty) {
      return !englishAndNumberCharacters.hasMatch(
        this!,
      ); // This will return true if it has arabic character
    } else {
      return false;
    }
  }

  bool get isEmail {
    final RegExp emailRegEx = RegExp(
      r'^(([^<>()[\]\\.,;:!@#$%&^\s@\"]+(\.[^<>()[\]\\.,;:!@#$%&^\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    if (isEmptyOrNull || !emailRegEx.hasMatch(this!)) {
      return false;
    } else {
      return true;
    }
  }

  bool get isNumeric {
    final numericRegex = RegExp(r'^[0-9]+$');
    if (isEmptyOrNull || !numericRegex.hasMatch(this!)) {
      return false;
    } else {
      return true;
    }
  }

  bool get isValidPhoneNumber {
    if (isEmptyOrNull || this!.length < 4 || this!.length > 12 || !isNumeric) {
      return false;
    } else {
      return true;
    }
  }

  bool get isValidName {
    if (isEmptyOrNull ||
        this!.length < 3 ||
        this!.length > 100 ||
        isHasSpecialCharacters()) {
      return false;
    } else {
      return true;
    }
  }

  bool isHasSpecialCharacters() {
    // Regular expression to detect special characters
    final specialCharRegex = RegExp(r'[!@#\$%\^\&*\)\(+=._-]');

    if (this != null && this!.isNotEmpty && specialCharRegex.hasMatch(this!)) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePasswordCharacters(String value) {
    // This pattern for
    // Minimum 1 Upper case,
    // Minimum 1 lowercase,
    // Minimum 1 Numeric Number,
    // Minimum 1 Special Character,
    // Common Allow Character ( ! @ # $ & * ~ )
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*\W).{4,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool validatePasswordRepeatedCharacters(String value) {
    // This pattern for
    // Will reject repeated characters (three or more)
    // It will return true if there are no repeated characters more than two times
    String pattern = r'(.)\1{2,}';
    RegExp regExp = RegExp(pattern);
    return !regExp.hasMatch(value);
  }

  bool validatePasswordForCommonSeriesCharacters(String value) {
    // Common series of characters that should not be allowed
    List<String> commonSeries = [
      'asdfghjkl',
      'qwertyuiop',
      'zxcvbnm',
      '01234567890',
      'abcdefghijklmnopqrstuvwxyz',
    ];

    // Fixed words that should be rejected outright
    List<String> fixedWords = ['welcome', 'monkey', 'letmein'];

    bool check = true;

    // Check if the value matches any fixed word
    for (var e in fixedWords) {
      if (value.toLowerCase().contains(e)) {
        check = false;
        return check;
      }
    }

    // No need to check for values shorter than 3 characters
    if (value.length < 3) {
      return check;
    } else {
      // Iterate through the common series
      for (String element in commonSeries) {
        for (int i = 0; i <= value.length - 3; ++i) {
          String subValue = value.substring(i, i + 3);

          // Check if the value contains the series in both lower and upper case
          if (element.contains(subValue.toLowerCase()) ||
              element.contains(subValue.toUpperCase())) {
            check = false;
            break;
          }

          // This part ensures that mixed-case series are also not allowed
          bool isSequentialMixedCase = true;
          for (int j = 0; j < 2; j++) {
            if (subValue[j].toLowerCase() != subValue[j + 1].toLowerCase() ||
                subValue[j] == subValue[j + 1]) {
              isSequentialMixedCase = false;
              break;
            }
          }

          if (isSequentialMixedCase) {
            check = false;
            break;
          }
        }

        if (!check) {
          break;
        }
      }
      return check;
    }
  }

  bool validatePasswordForTwoSideReadableWord(String value) {
    for (int i = 0; i <= value.length - 3; i++) {
      if (value[i] == value[i + 2]) {
        // Check for palindromes of length 3
        return false;
      }
    }
    return true;
  }
}

extension StringManipulation on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get reverse {
    return split('').reversed.join();
  }
}

extension StringConversion on String {
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  double? toDoubleOrNull() {
    return double.tryParse(this);
  }
}
