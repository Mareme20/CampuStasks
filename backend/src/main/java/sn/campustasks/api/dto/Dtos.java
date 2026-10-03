package sn.campustasks.api.dto;

import sn.campustasks.domain.enums.*;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Classe conteneur des objets de transfert de données (DTOs) de l'API REST.
 * Ces records Java immuables structurent les corps de requêtes et de réponses
 * tout en portant les contraintes de validation Jakarta (Bean Validation).
 */
public final class Dtos {

  private Dtos() {}

  // --------------------------------------------------------------------------
  // DTOs - Authentification
  // --------------------------------------------------------------------------

  /**
   * Requête d'inscription d'un nouvel étudiant.
   */
  public record RegisterRequest(
      @NotBlank(message = "Le nom est obligatoire")
      @Size(max = 120, message = "Le nom ne doit pas dépasser 120 caractères")
      String nom,

      @NotBlank(message = "L'adresse e-mail est obligatoire")
      @Email(message = "Le format de l'e-mail est invalide")
      String email,

      @NotBlank(message = "Le mot de passe est obligatoire")
      @Size(min = 8, max = 72, message = "Le mot de passe doit comporter entre 8 et 72 caractères")
      String password
  ) {}

  /**
   * Requête de connexion d'un étudiant.
   */
  public record LoginRequest(
      @NotBlank(message = "L'adresse e-mail est obligatoire")
      @Email(message = "Le format de l'e-mail est invalide")
      String email,

      @NotBlank(message = "Le mot de passe est obligatoire")
      String password
  ) {}

  /**
   * Réponse retournée après une authentification réussie (login ou register).
   */
  public record AuthResponse(
      String token,
      Long userId,
      String nom,
      String email
  ) {}

  // --------------------------------------------------------------------------
  // DTOs - Matières (Subjects)
  // --------------------------------------------------------------------------

  /**
   * Requête de création ou mise à jour d'une matière académique.
   */
  public record SubjectRequest(
      @NotBlank(message = "Le nom de la matière est obligatoire")
      @Size(max = 120, message = "Le nom ne doit pas dépasser 120 caractères")
      String nom,

      @Size(max = 500, message = "La description ne doit pas dépasser 500 caractères")
      String description
  ) {}

  /**
   * Données d'une matière renvoyées au client.
   */
  public record SubjectResponse(
      Long id,
      String nom,
      String description,
      LocalDateTime dateCreation,
      long nombreTaches
  ) {}

  // --------------------------------------------------------------------------
  // DTOs - Tâches (Tasks)
  // --------------------------------------------------------------------------

  /**
   * Requête de création ou mise à jour d'une tâche.
   */
  public record TaskRequest(
      @NotBlank(message = "Le titre de la tâche est obligatoire")
      @Size(max = 180, message = "Le titre ne doit pas dépasser 180 caractères")
      String titre,

      @Size(max = 2000, message = "La description ne doit pas dépasser 2000 caractères")
      String description,

      @NotNull(message = "La matière est obligatoire")
      Long subjectId,

      @NotNull(message = "La date limite est obligatoire")
      @FutureOrPresent(message = "La date limite ne peut pas être située dans le passé")
      LocalDateTime dateLimite,

      @NotNull(message = "La priorité est obligatoire")
      Priorite priorite,

      @NotNull(message = "Le statut est obligatoire")
      Statut statut
  ) {}

  /**
   * Données détaillées d'une tâche renvoyées au client.
   */
  public record TaskResponse(
      Long id,
      String titre,
      String description,
      Long subjectId,
      String subjectNom,
      LocalDateTime dateLimite,
      Priorite priorite,
      Statut statut,
      LocalDateTime dateCreation
  ) {}

  // --------------------------------------------------------------------------
  // DTOs - Tableau de bord (Dashboard)
  // --------------------------------------------------------------------------

  /**
   * Données synthétiques consolidées pour le tableau de bord de l'étudiant.
   */
  public record DashboardResponse(
      long aFaire,
      long enCours,
      long terminees,
      List<TaskResponse> prochainesEcheances,
      List<TaskResponse> enRetard
  ) {}
}
