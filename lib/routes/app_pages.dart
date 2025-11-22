import 'package:get/get.dart';
import 'package:traffic_app/modules/login/binding/login_binding.dart';
import 'package:traffic_app/modules/login/views/login_screen.dart';
import 'package:traffic_app/modules/signup/bindings/signup_binding.dart';
import 'package:traffic_app/modules/signup/views/signup_screen.dart';

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
