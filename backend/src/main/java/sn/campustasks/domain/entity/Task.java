package sn.campustasks.domain.entity;

import sn.campustasks.domain.enums.*;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/**
 * Entité représentant une tâche étudiante (devoir, projet, révision).
 * Chaque tâche possède une date limite, un niveau de priorité, un statut d'avancement,
 * et est liée à une matière ainsi qu'à son étudiant propriétaire.
 */
@Entity
@Table(
    name = "tasks",
    indexes = {
        @Index(name = "idx_task_owner_due", columnList = "owner_id, date_limite")
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Task extends BaseEntity {

    /** Intitulé de la tâche. */
    @Column(nullable = false, length = 180)
    private String titre;

    /** Description détaillée des consignes de la tâche. */
    @Column(length = 2000)
    private String description;

    /** Date et heure limites de rendu ou de réalisation. */
    @Column(name = "date_limite", nullable = false)
    private LocalDateTime dateLimite;

    /** Degré d'importance ou d'urgence (BASSE, MOYENNE, HAUTE). */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Priorite priorite;

    /** Statut courant de traitement (A_FAIRE, EN_COURS, TERMINEE). */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Statut statut;

    /** Matière à laquelle cette tâche est rattachée. */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    /** Utilisateur propriétaire de la tâche (garantissant l'isolation des données). */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;
}
