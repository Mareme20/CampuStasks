package sn.campustasks.service;

import sn.campustasks.api.dto.Dtos.SubjectRequest;
import sn.campustasks.api.dto.Dtos.SubjectResponse;
import java.util.List;

/**
 * Interface du service métier de gestion des matières.
 * Définit le contrat des opérations CRUD sur les matières pour l'utilisateur connecté.
 */
public interface SubjectService {

  /**
   * Récupère la liste de toutes les matières appartenant à l'utilisateur connecté.
   */
  List<SubjectResponse> list();

  /**
   * Crée une nouvelle matière pour l'utilisateur connecté.
   */
  SubjectResponse create(SubjectRequest request);

  /**
   * Met à jour une matière existante.
   */
  SubjectResponse update(Long id, SubjectRequest request);

  /**
   * Supprime une matière.
   * Si force=false et que des tâches y sont associées, une exception est levée.
   */
  void delete(Long id, boolean force);
}
