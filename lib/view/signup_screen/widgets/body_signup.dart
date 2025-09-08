import 'dart:developer';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:e_learning/core/logic/auth/auth_cubit.dart';
import 'package:e_learning/core/widgets/showMessage.dart';
import 'package:e_learning/view/signup_screen/widgets/times_taple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constant/constant.dart';
import '../../../core/models/stage_group_schedule_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/get_token.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../nav_button/views/nav_button_screen.dart';
import 'have_account.dart';

class BodySignUp extends StatefulWidget {
  const BodySignUp({super.key});

  @override
  State<BodySignUp> createState() => _BodySignUpState();
}

class _BodySignUpState extends State<BodySignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController parentPhoneController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DataList? selectedStage;

  bool isLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AuthCubit>().getAllStages();

  }
  @override
  Widget build(BuildContext context) {


    /// Builds a table cell with consistent styling.
    return  BlocConsumer<AuthCubit, AuthState>(
      builder: (BuildContext context, state) {
        AuthCubit cubit = context.read<AuthCubit>();


        return (state is SignupLoading || state is GetStagesLoading|| state is GetStagesError||isLoading)
            ? LoadingWidget()
            : Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
              child: Column(
                children: [
                  SizedBox(height: kHeight33),
                  CustomTextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "أدخل الاسم";
                      }
                      return null;
                    },
                    hintText: "الاسم كامل",
                    controller: nameController,
                  ),
                  SizedBox(height: kHeight16),
                  CustomTextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "أدخل البريد الإلكتروني";
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return "البريد إلكتروني غير صالح";
                      }
                      return null;
                    },
                    hintText: "البريد الإلكتروني",
                    textInputType: TextInputType.emailAddress,
                    controller: emailController,
                  ),
                  SizedBox(height: kHeight16),
                  CustomTextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "أدخل كلمة المرور";
                      }
                      if (value.length < 6) {
                        return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                      }
                      return null;
                    },
                    hintText: "كلمة المرور",
                    isPassword: true,
                    controller: passController,
                  ),
                  SizedBox(height: kHeight16),
                  CustomTextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "أدخل رقم الهاتف";
                      }
                      if(parentPhoneController.text==phoneController.text){
                        return "رقم هاتف ولي الأمر يجب أن يختلف عن رقم هاتف الطالب";

                      }
                      final phoneRegExp = RegExp(r'^\d{11}$');
                      if (!phoneRegExp.hasMatch(value)) {
                        return "رقم الهاتف غير صالح، يجب أن يحتوي على 11 رقمًا";
                      }
                      return null;
                    },
                    hintText: "رقم الهاتف",
                    controller: phoneController,
                    textInputType: TextInputType.numberWithOptions(),
                  ),
                  SizedBox(height: kHeight16),
                  CustomTextFormField(
                    validator: (value) {
                      if(parentPhoneController.text==phoneController.text){
                        return "رقم هاتف ولي الأمر يجب أن يختلف عن رقم هاتف الطالب";

                      }
                      if (value == null || value.isEmpty) {
                        return "أدخل رقم هاتف ولي الأمر";
                      }
                      final phoneRegExp = RegExp(r'^\d{11}$');
                      if (!phoneRegExp.hasMatch(value)) {
                        return "رقم الهاتف غير صالح، يجب أن يحتوي على 11 رقمًا";
                      }
                      return null;
                    },
                    hintText: "رقم هاتف ولي الأمر",
                    controller: parentPhoneController,
                    textInputType: TextInputType.numberWithOptions(),
                  ),
                  SizedBox(height: kHeight16),
                  CustomDropdown<DataList>(
                    hintText: 'اختر المرحلة',
                    items: cubit.dataListDropdownItems,
                    onChanged: (value) {
                      setState(() {
                        selectedStage = value!;
                      });
                      log("Selected stage: $value");
                    },
                    decoration: CustomDropdownDecoration(
                      closedFillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.transparent,
                      expandedFillColor: Theme.of(context).cardColor,
                      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle ?? TextStyle(color: Theme.of(context).hintColor),
                      listItemStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                      closedShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Color(0xff424242)
                              : Color(0xffF2F3F3),
                        ),
                      ],
                      searchFieldDecoration: SearchFieldDecoration(
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                  SizedBox(height: kHeight16),

                  SizedBox(height: kHeight33),
                  CustomButton(
                    onPressed: () async {
                      if (selectedStage == null) {
                        ShowMessage.showToast("يرجى اختيار المرحلة");
                        return;
                      }

                      if (formKey.currentState!.validate()) {
                        String? token = await DeviceTokenHelper.getFCMToken();
                        String deviceId = await DeviceTokenHelper.getDeviceId();
                        setState(() {
                          isLoading=true;
                        });
                        await cubit.signUp(
                          name: nameController.text,
                          email: emailController.text,
                          password: passController.text,
                          phone: phoneController.text,
                          stageId: selectedStage!.id!, fcmToken: token??'', device_id: deviceId, parent_phone: parentPhoneController.text,
                        );
                      }
                    },
                    text: "حساب جديد",
                  ),
                  SizedBox(height: kHeight33),
                  const HaveAnAccountWidget(),
                  SizedBox(height: kHeight16),
                ],
              ),
            ),
          ),
        );
      },
        listener: (context, state) {
          if (state is SignupError ) {
            ShowMessage.showToast(state.errorMessage);

          }
          // if(state is LoginSuccess|| state is GoogleLoginSuccess || state is FacebookLoginSuccess){
          //   if(state is LoginSuccess|| state is GoogleLoginSuccess ){
          if(state is SignupSuccess ){
            Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavButton(),));
          }
        }
    );

  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
