package sn.campustasks.api.dto;
import sn.campustasks.domain.enums.*; import jakarta.validation.constraints.*; import java.time.LocalDateTime; import java.util.List;
public final class Dtos {
 private Dtos(){}
 public record RegisterRequest(@NotBlank @Size(max=120) String nom,@NotBlank @Email String email,@NotBlank @Size(min=8,max=72) String password){}
 public record LoginRequest(@NotBlank @Email String email,@NotBlank String password){}
 public record AuthResponse(String token,Long userId,String nom,String email){}
 public record SubjectRequest(@NotBlank @Size(max=120) String nom,@Size(max=500) String description){}
 public record SubjectResponse(Long id,String nom,String description,LocalDateTime dateCreation,long nombreTaches){}
 public record TaskRequest(@NotBlank @Size(max=180) String titre,@Size(max=2000) String description,@NotNull Long subjectId,@NotNull @FutureOrPresent LocalDateTime dateLimite,@NotNull Priorite priorite,@NotNull Statut statut){}
 public record TaskResponse(Long id,String titre,String description,Long subjectId,String subjectNom,LocalDateTime dateLimite,Priorite priorite,Statut statut,LocalDateTime dateCreation){}
 public record DashboardResponse(long aFaire,long enCours,long terminees,List<TaskResponse> prochainesEcheances,List<TaskResponse> enRetard){}
}
