import '../core/network/api_client.dart'; import '../core/storage/token_storage.dart';
class AuthRepository {
 final ApiClient api; final TokenStorage storage; AuthRepository(this.api,this.storage);
 Future<void> login(String e,String p)async{final x=await api.send('POST','/auth/login',body:{'email':e,'password':p});await storage.save(x['token']);}
 Future<void> register(String n,String e,String p)async{final x=await api.send('POST','/auth/register',body:{'nom':n,'email':e,'password':p});await storage.save(x['token']);}
 Future<void> logout()=>storage.clear(); Future<bool> logged()=>storage.read().then((x)=>x!=null);
}
