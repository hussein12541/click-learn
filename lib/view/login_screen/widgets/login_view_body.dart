import 'dart:developer';

import 'package:e_learning/core/logic/auth/auth_cubit.dart';
import 'package:e_learning/core/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constant/constant.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/get_token.dart';
import '../../../core/widgets/showMessage.dart';
import '../../nav_button/views/nav_button_screen.dart';
import '../../reset_password_screen/reset_password_screen.dart';
import 'dont_have_account.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      builder: (context, state) {
        AuthCubit cubit = context.read<AuthCubit>();
        return (state is LoginLoading ||isLoading )
            ? const LoadingWidget()
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [

                        SizedBox(
                          height: kHeight16,
                        ),
                        SvgPicture.asset('assets/images/images/vecteezy_studying.svg',fit:BoxFit.cover ,height: 300.h,),
                        SizedBox(
                          height: kHeight33,
                        ),

                        CustomTextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "أدخل بريدك الإلكتروني";
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value)) {
                              return "البريد الإلكتروني غير صحيح";
                            }
                            return null;
                          },
                          hintText: "البريد الإلكتروني",
                          textInputType: TextInputType.emailAddress,
                          controller: emailController,
                        ),
                        SizedBox(
                          height: kHeight16,
                        ),
                        CustomTextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "أدخل كلمة المرور";
                            }
                            if (value.length < 6) {
                              return "ييجب أن لا تق كلمة المرور عن 6 أحرف";
                            }
                            return null;
                          },

                          hintText: "كلمة المرور",
                          isPassword: true,
                          controller: passController,
                        ),
                        SizedBox(
                          height: kHeight16,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordScreen(),));
                                },
                                child: Text(
                                  "نسيت كلمة المرور",
                                  style: TextStyle(
                                    color: kLightPrimaryColor,
                                    fontSize: kFontSize13,
                                  ),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: kHeight33,
                        ),
                        CustomButton(
                          onPressed: () async {
                        if(formKey.currentState!.validate()){
                          String? token = await DeviceTokenHelper.getFCMToken();
                          String deviceId = await DeviceTokenHelper.getDeviceId();
                          log("+++++++++++++++++++++==============$deviceId");
                          setState(() {
                            isLoading=true;
                          });
                          await cubit.login(
                              email: emailController.text,
                              password: passController.text,
                              context: context, fcm_token:token??'', device_id: deviceId );
                        }


                          },
                          text: "تسجيل الدخول",
                        ),
                        SizedBox(
                          height: kHeight33,
                        ),
                        const DontHaveAnAccountWidget(),
                        SizedBox(
                          height: kHeight33,
                        ),


                        // SizedBox(
                        //   height: kHeight24,
                        // ),
                        // SocialLoginButton(
                        //   onPressed: () async {
                        //     await cubit.facebookSignIn();
                        //   },
                        //   image: 'assets/image/images/facebook.svg',
                        //   title: S.of(context).login_with_facebook,
                        // ),
                      ],
                    ),
                  ),
                ),
              );
      },
      listener: (context, state) {
        if (state is LoginError ) {
          ShowMessage.showToast(state.errorMessage);

        }
        // if(state is LoginSuccess|| state is GoogleLoginSuccess || state is FacebookLoginSuccess){
        //   if(state is LoginSuccess|| state is GoogleLoginSuccess ){
          if(state is LoginSuccess ){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavButton(),));
          }
        }
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
}
