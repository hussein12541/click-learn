import 'package:bloc/bloc.dart';
import 'package:e_learning/core/api_services/api_services.dart';
import 'package:meta/meta.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../../constant/constant.dart';
part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordInitial());

  final ApiServices _api =ApiServices();
  Future<void> sendEmail({required String toEmail}) async {
    emit(ResetPasswordLoading());

    try {
      final response = await _api.getData(path: "users?select=password&email=eq.$toEmail");
      if (response.data == null || response.data.isEmpty) {
        emit(ResetPasswordError());
        print('No user found with this email.');
        return;
      }
      String body = response.data[0]["password"];



      String username = 'husseineducationlearning@gmail.com';
      String password = 'johw evxz wfum lmno'; // تأكد من أن هذا App Password




      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, kAppName)
        ..recipients.add(toEmail)
        ..subject = 'استعادة كلمة المرور'
        ..html = '''
  <!DOCTYPE html>
  <html lang="ar" dir="rtl">
  <head>
    <meta charset="UTF-8">
    <style>
      body {
        font-family: 'Tahoma', sans-serif;
        background-color: #f9f9f9;
        color: #333;
        padding: 20px;
        line-height: 1.6;
      }
      .container {
        background-color: #fff;
        border: 1px solid #ddd;
        padding: 20px;
        border-radius: 10px;
        max-width: 500px;
        margin: auto;
        box-shadow: 0 0 10px rgba(0,0,0,0.05);
      }
      .header {
        font-size: 20px;
        font-weight: bold;
        color: #007bff;
        margin-bottom: 10px;
      }
      .password {
        background-color: #f1f1f1;
        padding: 10px;
        border-radius: 5px;
        font-weight: bold;
        direction: ltr;
        text-align: center;
        margin: 15px 0;
      }
      .footer {
        font-size: 12px;
        color: #888;
        margin-top: 20px;
        text-align: center;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">مرحبًا بك!</div>
      <p>لقد طلبت استعادة كلمة المرور الخاصة بك من خلال تطبيق <strong>${kAppName}</strong>.</p>
      <p>كلمة المرور الخاصة بك هي:</p>
      <div class="password">$body</div>
      <p>من فضلك احتفظ بها في مكان آمن ولا تشاركها مع أي شخص.</p>
      <p>إذا وجدت هذه الرسالة في البريد العشوائي، يُرجى نقلها إلى البريد الوارد وإضافة بريدنا الإلكتروني إلى جهات الاتصال لديك.</p>
      <div class="footer">
        &copy; ${DateTime.now().year}${kAppName}. جميع الحقوق محفوظة.
      </div>
    </div>
  </body>
  </html>
''';


      final sendReport = await send(message, smtpServer);
      print('Email sent: $sendReport');
      emit(ResetPasswordSuccess());
    } on MailerException catch (e) {
      emit(ResetPasswordError());
      print('Email not sent.');
      print('Unknown error: $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
