package sn.campustasks.domain.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * Classe de base abstraite (MappedSuperclass) pour toutes les entités du domaine.
 * Elle factorise l'identifiant technique auto-incrémenté ainsi que les dates d'audit
 * (date de création et date de dernière modification).
 */
@MappedSuperclass
@Getter
@Setter
public abstract class BaseEntity {

    /** Identifiant unique de l'entité généré automatiquement (clé primaire). */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Date et heure de création de l'enregistrement, renseignées automatiquement par Hibernate. */
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    /** Date et heure de la dernière mise à jour de l'enregistrement. */
    @UpdateTimestamp
    @Column
    private LocalDateTime dateModification;
}
