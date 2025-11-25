import 'package:get/get.dart';

import '../modules/login/binding/login_binding.dart';
import '../modules/login/views/login_screen.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
    ),
  ];
}
