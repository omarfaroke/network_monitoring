import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  UserModel? currentUser;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiClient.instance.dio.post(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    await ApiClient.instance.saveToken(token);

    currentUser = UserModel.fromMap(data['user'] as Map<String, dynamic>);
    return currentUser!;
  }

  Future<UserModel?> restoreSession() async {
    final token = await ApiClient.instance.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await ApiClient.instance.dio.get('/api/user/me');
      currentUser = UserModel.fromMap(response.data as Map<String, dynamic>);
      return currentUser;
    } catch (_) {
      await ApiClient.instance.clearToken();
      currentUser = null;
      return null;
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.clearToken();
    currentUser = null;
  }
}
