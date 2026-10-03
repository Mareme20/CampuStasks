package sn.campustasks.repository;

import sn.campustasks.domain.entity.Subject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

/**
 * Interface d'accès aux données (Spring Data JPA) pour les matières.
 * Toutes les requêtes intègrent l'identifiant du propriétaire (ownerId)
 * pour assurer l'isolation étanche entre étudiants.
 */
public interface SubjectRepository extends JpaRepository<Subject, Long> {

    /**
     * Récupère la liste des matières d'un utilisateur, triées par ordre alphabétique.
     *
     * @param ownerId Identifiant de l'utilisateur connecté
     * @return Liste ordonnée des matières
     */
    List<Subject> findAllByOwnerIdOrderByNomAsc(Long ownerId);

    /**
     * Recherche une matière par son ID en vérifiant qu'elle appartient bien à l'utilisateur.
     *
     * @param id Identifiant de la matière
     * @param ownerId Identifiant de l'utilisateur connecté
     * @return Optional contenant la matière si trouvée et autorisée
     */
    Optional<Subject> findByIdAndOwnerId(Long id, Long ownerId);

    /**
     * Vérifie l'existence d'une matière appartenant à l'utilisateur donné.
     *
     * @param id Identifiant de la matière
     * @param ownerId Identifiant de l'utilisateur connecté
     * @return true si la matière existe pour cet utilisateur
     */
    boolean existsByIdAndOwnerId(Long id, Long ownerId);

    /**
     * Compte le nombre de tâches associées à une matière donnée.
     * Utilisé lors de la suppression pour empêcher les suppressions accidentelles
     * sans confirmation explicite (force=true).
     *
     * @param id Identifiant de la matière
     * @return Nombre de tâches rattachées
     */
    @Query("select count(t) from Task t where t.subject.id = :id")
    long countTasks(@Param("id") Long id);
}
