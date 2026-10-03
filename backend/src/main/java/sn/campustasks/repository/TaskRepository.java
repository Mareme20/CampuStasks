package sn.campustasks.repository;
import sn.campustasks.domain.entity.Task; import sn.campustasks.domain.enums.Statut;
import org.springframework.data.jpa.repository.*; import org.springframework.data.repository.query.Param; import java.time.LocalDateTime; import java.util.*;
public interface TaskRepository extends JpaRepository<Task,Long> {
 @Query("select t from Task t join fetch t.subject where t.owner.id=:ownerId and (:subjectId is null or t.subject.id=:subjectId) and (:statut is null or t.statut=:statut) order by t.dateLimite asc")
 List<Task> search(@Param("ownerId")Long ownerId,@Param("subjectId")Long subjectId,@Param("statut")Statut statut);
 Optional<Task> findByIdAndOwnerId(Long id,Long ownerId);
 long countByOwnerIdAndStatut(Long ownerId,Statut statut);
 @Query("select t from Task t join fetch t.subject where t.owner.id=:ownerId and t.statut<>:statut and t.dateLimite<:now order by t.dateLimite asc")
 List<Task> findLate(@Param("ownerId")Long ownerId,@Param("statut")Statut statut,@Param("now")LocalDateTime now);
 @Query("select t from Task t join fetch t.subject where t.owner.id=:ownerId and t.dateLimite>=:now and t.statut<>:statut order by t.dateLimite asc")
 List<Task> findUpcoming(@Param("ownerId")Long ownerId,@Param("statut")Statut statut,@Param("now")LocalDateTime now);
}
