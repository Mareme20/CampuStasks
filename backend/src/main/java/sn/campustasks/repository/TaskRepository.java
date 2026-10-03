package sn.campustasks.repository;

import sn.campustasks.domain.entity.Task;
import sn.campustasks.domain.enums.Statut;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Interface d'accès aux données (Spring Data JPA) pour les tâches.
 * Propose des requêtes de recherche multicritères et de calcul pour le tableau de bord,
 * avec jointure optimisée (join fetch) pour éviter le problème N+1 requêtes.
 */
public interface TaskRepository extends JpaRepository<Task, Long> {

    /**
     * Recherche des tâches de l'utilisateur avec filtres optionnels par matière et par statut.
     * Le join fetch charge immédiatement l'entité Subject associée.
     *
     * @param ownerId Identifiant de l'utilisateur connecté
     * @param subjectId Filtre optionnel sur la matière (null = toutes)
     * @param statut Filtre optionnel sur le statut (null = tous)
     * @return Liste des tâches correspondantes triées par date limite croissante
     */
    @Query("select t from Task t join fetch t.subject " +
           "where t.owner.id = :ownerId " +
           "and (:subjectId is null or t.subject.id = :subjectId) " +
           "and (:statut is null or t.statut = :statut) " +
           "order by t.dateLimite asc")
    List<Task> search(@Param("ownerId") Long ownerId,
                      @Param("subjectId") Long subjectId,
                      @Param("statut") Statut statut);

    /**
     * Recherche une tâche par son identifiant en vérifiant son appartenance à l'utilisateur.
     *
     * @param id Identifiant de la tâche
     * @param ownerId Identifiant de l'utilisateur connecté
     * @return Optional contenant la tâche si trouvée et autorisée
     */
    Optional<Task> findByIdAndOwnerId(Long id, Long ownerId);

    /**
     * Compte le nombre de tâches d'un utilisateur ayant un statut donné.
     *
     * @param ownerId Identifiant de l'utilisateur connecté
     * @param statut Statut recherché (A_FAIRE, EN_COURS, TERMINEE)
     * @return Nombre de tâches
     */
    long countByOwnerIdAndStatut(Long ownerId, Statut statut);

    /**
     * Récupère les tâches en retard (non terminées et dont la date limite est dépassée).
     *
     * @param ownerId Identifiant de l'utilisateur connecté
     * @param statut Statut exclu (TERMINEE)
     * @param now Date/heure courante de référence
     * @return Liste des tâches en retard triées par échéance
     */
    @Query("select t from Task t join fetch t.subject " +
           "where t.owner.id = :ownerId " +
           "and t.statut <> :statut " +
           "and t.dateLimite < :now " +
           "order by t.dateLimite asc")
    List<Task> findLate(@Param("ownerId") Long ownerId,
                        @Param("statut") Statut statut,
                        @Param("now") LocalDateTime now);

    /**
     * Récupère les prochaines échéances à venir (non terminées et dont la date limite est future).
     *
     * @param ownerId Identifiant de l'utilisateur connecté
     * @param statut Statut exclu (TERMINEE)
     * @param now Date/heure courante de référence
     * @return Liste des tâches futures triées par date limite croissante
     */
    @Query("select t from Task t join fetch t.subject " +
           "where t.owner.id = :ownerId " +
           "and t.dateLimite >= :now " +
           "and t.statut <> :statut " +
           "order by t.dateLimite asc")
    List<Task> findUpcoming(@Param("ownerId") Long ownerId,
                           @Param("statut") Statut statut,
                           @Param("now") LocalDateTime now);
}
