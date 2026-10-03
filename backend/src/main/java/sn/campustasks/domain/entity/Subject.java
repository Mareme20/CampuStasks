package sn.campustasks.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

/**
 * Entité représentant une matière académique (ex: Algorithmique, Réseaux, Génie Logiciel).
 * Une matière est rattachée à un utilisateur propriétaire et contient plusieurs tâches.
 */
@Entity
@Table(name = "subjects")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Subject extends BaseEntity {

    /** Intitulé de la matière. */
    @Column(nullable = false, length = 120)
    private String nom;

    /** Description optionnelle ou détails pédagogiques de la matière. */
    @Column(length = 500)
    private String description;

    /** Utilisateur propriétaire de cette matière. */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    /** Liste des tâches associées à cette matière. */
    @OneToMany(mappedBy = "subject", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Task> tasks = new ArrayList<>();
}
