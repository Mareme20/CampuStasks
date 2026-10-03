import 'package:flutter/material.dart';
import 'core/network/api_client.dart'; import 'core/storage/token_storage.dart'; import 'repositories/auth_repository.dart'; import 'repositories/task_repository.dart'; import 'screens/login_screen.dart'; import 'screens/home_screen.dart';
void main(){final st=TokenStorage();final api=ApiClient(st);final auth=AuthRepository(api,st);final tasks=TaskRepository(api);runApp(App(auth:auth,tasks:tasks));}
class App extends StatelessWidget {
 final AuthRepository auth; final TaskRepository tasks; const App({super.key,required this.auth,required this.tasks});
 Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'CampusTasks',theme:ThemeData(useMaterial3:true,colorSchemeSeed:Colors.indigo),
 home:FutureBuilder<bool>(future:auth.logged(),builder:(c,s)=>!s.hasData?const Scaffold(body:Center(child:CircularProgressIndicator())):s.data!?HomeScreen(auth:auth,tasks:tasks):LoginScreen(auth:auth,tasks:tasks)));
}
