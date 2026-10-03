import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
 final int status; final String message;
 ApiException(this.status,this.message);
 String toString()=>message;
}
class ApiClient {
 final TokenStorage storage; ApiClient(this.storage);
 Future<dynamic> send(String method,String path,{Map<String,dynamic>? body,Map<String,String>? query}) async {
  final token=await storage.read();
  final uri=Uri.parse('${AppConfig.apiBaseUrl}$path').replace(queryParameters:query);
  final headers={'Content-Type':'application/json','Accept':'application/json',if(token!=null)'Authorization':'Bearer $token'};
  late http.Response r; final data=body==null?null:jsonEncode(body);
  switch(method){case 'GET':r=await http.get(uri,headers:headers);break;case 'POST':r=await http.post(uri,headers:headers,body:data);break;case 'PUT':r=await http.put(uri,headers:headers,body:data);break;case 'DELETE':r=await http.delete(uri,headers:headers);break;default:throw ArgumentError(method);}
  if(r.statusCode<200||r.statusCode>=300){String m='Une erreur est survenue.';try{m=jsonDecode(r.body)['message']??m;}catch(_){ }throw ApiException(r.statusCode,m);}
  return r.body.isEmpty?{}:jsonDecode(r.body);
 }
 Future<List<dynamic>> list(String path,{Map<String,String>? query}) async => List<dynamic>.from(await send('GET',path,query:query));
}
