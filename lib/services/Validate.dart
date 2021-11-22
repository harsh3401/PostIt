class AuthValidation{

    static String? nameValidator({required String? name}){
       if(name!.isEmpty){
         return "The name field can't be empty";
       }

       return null;
    }

    static String? emailValidator({required String? email}){
        if(email!.isEmpty){
          return "The email field can't be empty";
        }
        RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
        if(!emailRegExp.hasMatch(email)){
          return "The email you've entered is not valid";
        }

        return null;
    }

    static String? passwordValidator({required String? password}){
      if(password!.isEmpty){
        return "Enter the password";
      }

      RegExp passwordRegExp = RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&-+=()])(?=\\S+$).{8, 20}$");


      if(!passwordRegExp.hasMatch(password)){
        return "The password you entered doesn't meet the requirements";
      }

      return null;

    }

}