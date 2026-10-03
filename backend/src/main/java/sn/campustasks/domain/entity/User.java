package sn.campustasks.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

/**
 * Entité représentant un utilisateur (étudiant) du système CampusTasks.
 * Chaque utilisateur possède ses propres matières et tâches en isolation complète.
 */
@Entity
@Table(
    name = "users",
    uniqueConstraints = @UniqueConstraint(name = "uk_user_email", columnNames = "email")
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity {

    /** Nom complet de l'étudiant. */
    @Column(nullable = false, length = 120)
    private String nom;

    /** Adresse e-mail unique servant d'identifiant de connexion. */
    @Column(nullable = false, length = 180)
    private String email;

    /** Empreinte du mot de passe haché par l'algorithme BCrypt. */
    @Column(nullable = false, length = 100)
    private String passwordHash;

    /** Liste des matières créées par cet utilisateur. */
    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Subject> subjects = new ArrayList<>();
}
