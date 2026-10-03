package sn.campustasks.repository;
import sn.campustasks.domain.entity.Subject; import org.springframework.data.jpa.repository.*; import org.springframework.data.repository.query.Param; import java.util.*;
public interface SubjectRepository extends JpaRepository<Subject,Long> {
 List<Subject> findAllByOwnerIdOrderByNomAsc(Long ownerId);
 Optional<Subject> findByIdAndOwnerId(Long id,Long ownerId);
 boolean existsByIdAndOwnerId(Long id,Long ownerId);
 @Query("select count(t) from Task t where t.subject.id = :id") long countTasks(@Param("id") Long id);
}
