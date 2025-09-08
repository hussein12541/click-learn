import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return (!isDark)? Center(child: Lottie.asset('assets/json/loading.json')) : Center(child: Lottie.asset('assets/json/dark_loading.json'));

  }
}
