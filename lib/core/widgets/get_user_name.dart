// import 'package:supabase_flutter/supabase_flutter.dart';
//
// Future<String?> getUserName({required String userId}) async {
//   try {
//     final response = await Supabase.instance.client
//         .from('users')
//         .select('name')
//         .eq('id', userId)
//         .single();
//
//     return response['name'] as String?;
//   } catch (e) {
//     print('Error fetching name: $e');
//     return null;
//   }
// }
