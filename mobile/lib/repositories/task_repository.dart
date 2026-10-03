import '../core/network/api_client.dart'; import '../models/models.dart';
class TaskRepository {
 final ApiClient api; TaskRepository(this.api);
 Future<List<Subject>> subjects()async=> (await api.list('/subjects')).map((e)=>Subject.fromJson(e)).toList();
 Future<List<Task>> tasks({int? subjectId,TaskStatus? status})async{
  final q=<String,String>{};if(subjectId!=null)q['subjectId']='$subjectId';if(status!=null)q['statut']=statusTo(status);
  return (await api.list('/tasks',query:q)).map((e)=>Task.fromJson(e)).toList();
 }
 Future<void> addSubject(String n)=>api.send('POST','/subjects',body:{'nom':n,'description':''});
 Future<void> addTask(String t,String d,int s,DateTime due,Priority p)=>api.send('POST','/tasks',body:{'titre':t,'description':d,'subjectId':s,'dateLimite':due.toIso8601String(),'priorite':priorityTo(p),'statut':'A_FAIRE'});
}
