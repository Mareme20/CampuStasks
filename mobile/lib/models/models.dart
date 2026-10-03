enum TaskStatus { aFaire, enCours, terminee }
enum Priority { basse, moyenne, haute }
TaskStatus statusFrom(String s)=>{'A_FAIRE':TaskStatus.aFaire,'EN_COURS':TaskStatus.enCours,'TERMINEE':TaskStatus.terminee}[s]??TaskStatus.aFaire;
Priority priorityFrom(String s)=>{'BASSE':Priority.basse,'MOYENNE':Priority.moyenne,'HAUTE':Priority.haute}[s]??Priority.moyenne;
String statusTo(TaskStatus s)=>{TaskStatus.aFaire:'A_FAIRE',TaskStatus.enCours:'EN_COURS',TaskStatus.terminee:'TERMINEE'}[s]!;
String priorityTo(Priority p)=>{Priority.basse:'BASSE',Priority.moyenne:'MOYENNE',Priority.haute:'HAUTE'}[p]!;
class Subject {
 final int id; final String nom; final String? description; final int nombreTaches;
 Subject({required this.id,required this.nom,this.description,required this.nombreTaches});
 factory Subject.fromJson(Map<String,dynamic> j)=>Subject(id:j['id'],nom:j['nom'],description:j['description'],nombreTaches:j['nombreTaches']??0);
}
class Task {
 final int id; final String titre; final String? description; final int subjectId; final String subjectNom; final DateTime dateLimite; final Priority priorite; final TaskStatus statut;
 Task({required this.id,required this.titre,this.description,required this.subjectId,required this.subjectNom,required this.dateLimite,required this.priorite,required this.statut});
 factory Task.fromJson(Map<String,dynamic> j)=>Task(id:j['id'],titre:j['titre'],description:j['description'],subjectId:j['subjectId'],subjectNom:j['subjectNom'],dateLimite:DateTime.parse(j['dateLimite']),priorite:priorityFrom(j['priorite']),statut:statusFrom(j['statut']));
}
