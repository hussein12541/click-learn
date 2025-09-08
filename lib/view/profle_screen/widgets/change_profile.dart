import 'package:e_learning/core/api_services/api_services.dart';
import 'package:e_learning/core/logic/get_user_data/get_user_data_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  const EditProfileScreen({super.key, required this.name, required this.phone});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text=widget.name;
    phoneController.text=widget.phone;
  }


  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();

      try {
        if (userId != null) {
          await ApiServices().patchData(
            path: 'users?id=eq.$userId',
            data: {
              'name': name,
              'phone': phone,
            },
          );
          await context.read<GetUserDataCubit>().fetchUserDataAndCheckExistence( id:Supabase.instance.client.auth.currentUser?.id??"" );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث البيانات بنجاح ✅'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحديث البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator ??
              (value) {
            if (value == null || value.trim().isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(
                label: 'الاسم الكامل',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              buildTextField(
                label: 'رقم الهاتف',
                controller: phoneController,
                inputType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'رقم الهاتف مطلوب';
                  }
                  if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                    return 'رقم الهاتف يجب أن يكون 11 رقمًا';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: updateUserData,
                icon: const Icon(Icons.save),
                label: const Text('حفظ التغييرات'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
