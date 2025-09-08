import 'package:e_learning/core/constant/constant.dart';
import 'package:e_learning/core/logic/reset_password/reset_password_cubit.dart';
import 'package:e_learning/core/widgets/custom_button.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController=TextEditingController();


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetPasswordCubit>(
      create: (context) => ResetPasswordCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("نسيت كلمة المرور"),
          centerTitle: true,
        ),
        body: BlocConsumer<ResetPasswordCubit,ResetPasswordState>(
          builder: (context, state) {
            if(state is ResetPasswordLoading){
              return LoadingWidget();
            }else{

              return SingleChildScrollView(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  SizedBox(height: 10.h,),

                  Text("لا تقلق, ما عليك سوى كتابة بريدك الإلكتروني و سنرسل لك كلمة المرور.",style: TextStyle(fontSize: kFontSize16,color: Color(0xff616A6B)),),

                  SizedBox(height: 30.h,),
                  CustomTextFormField(hintText: "البريد الإلكتروني", controller: emailController)
                  , SizedBox(height: 30.h,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomButton(onPressed: () async {
                      await context.read<ResetPasswordCubit>().sendEmail(toEmail: emailController.text);
                    }, text:"نسيت كلمة المرور" ),
                  )
                ],),
              ),);
            }
          }, listener: (BuildContext context, ResetPasswordState state) {
            if(state is ResetPasswordSuccess){
              emailController.clear();
              ShowMessage.showToast("تمت العملية بنجاح أفحص بريدك و إن لم تجد الرسالة أفحص spam",backgroundColor: kLight2PrimaryColor);

            }
            if(state is ResetPasswordError){
              ShowMessage.showToast("البريد الإلكتروني غير صحيح",);

            }
        },
        ),
      ),
    );
  }
}
