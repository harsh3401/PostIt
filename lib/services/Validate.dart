class AuthValidation {
  static String? nameValidator({required String? name}) {
    if (name!.isEmpty) {
      return "The name field can't be empty";
    }

    return null;
  }

  static String? questionValidator({required String? question}) {
    if (question!.isEmpty) {
      return "Question field can't be empty";
    }
    if (question.length < 5) {
      return "Question length too short";
    } else if (question.length > 50) {
      return "Queston length too long";
    }
  }

  static String? descValidator({required String? desc}) {
    if (desc!.isEmpty) {
      return "Question field can't be empty";
    }
    if (desc.length < 10) {
      return "Question length too short";
    } else if (desc.length > 200) {
      return "Queston length too long";
    }
  }

  static String? emailValidator({required String? email}) {
    if (email!.isEmpty) {
      return "The email field can't be empty";
    }
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!emailRegExp.hasMatch(email)) {
      return "The email you've entered is not valid";
    }

    return null;
  }

  static String? passwordValidator({required String? password}) {
    if (password!.isEmpty) {
      return "Enter the password";
    }

    RegExp passwordRegExp = RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$");

    if (!passwordRegExp.hasMatch(password)) {
      return "The password you entered doesn't meet the requirements";
    }

    return null;
  }
}
