import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class TokenStorage {
  static const key='access_token';
  final storage=const FlutterSecureStorage();
  Future<void> save(String token)=>storage.write(key:key,value:token);
  Future<String?> read()=>storage.read(key:key);
  Future<void> clear()=>storage.delete(key:key);
}
