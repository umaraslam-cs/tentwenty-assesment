import 'package:fluttertoast/fluttertoast.dart';

import '../core/constants/app_colors.dart';

class AppToast {
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.green,
      textColor: AppColors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
    );
  }

  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.errorRed,
      textColor: AppColors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
    );
  }

  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.welcomeButton,
      textColor: AppColors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
    );
  }
}
