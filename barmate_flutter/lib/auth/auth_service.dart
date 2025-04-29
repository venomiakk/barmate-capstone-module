import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  
  final SupabaseClient supabase = Supabase.instance.client;
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
       password: password);
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  String? getAuthUserEmail() {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
  
  Future<String?> fetchUserLoginById(String userId) async {
    try {
      final response = await supabase.rpc('get_user_login_by_id', params: {'u_id': userId});
      return response;
    } catch (error) {
      print('Błąd podczas wywoływania funkcji RPC: $error');
      return 'guest';
    }
  }

  Future<String?> setLoginById(String userId, String userLogin) async {
    try {
      final response = await supabase.rpc('set_user_login_by_id', params: {'u_id': userId,'u_login': userLogin});
      return response;
    } catch (error) {
      print('Błąd podczas wywoływania funkcji RPC: $error');
      return null;
    }

    
  }

}