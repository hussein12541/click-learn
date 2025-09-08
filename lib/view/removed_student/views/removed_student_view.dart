import 'package:flutter/material.dart';


import '../widgets/kicked_out_widget.dart';

class KickedOutPage extends StatelessWidget {
  final bool samePhone;
  const KickedOutPage({super.key, required this.samePhone});

  @override

  Widget build(BuildContext context) {

    return Scaffold(
      body:KickedOutWidget(samePhone: samePhone,)
    );
  }
}


