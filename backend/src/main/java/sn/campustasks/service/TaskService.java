package sn.campustasks.service;

import sn.campustasks.api.dto.Dtos.DashboardResponse;
import sn.campustasks.api.dto.Dtos.TaskRequest;
import sn.campustasks.api.dto.Dtos.TaskResponse;
import sn.campustasks.domain.enums.Statut;
import java.util.List;

/**
 * Interface du service métier de gestion des tâches.
 * Définit le contrat des opérations sur les tâches et le tableau de bord.
 */
public interface TaskService {

  /**
   * Recherche et filtre les tâches de l'utilisateur connecté par matière et/ou statut.
   */
  List<TaskResponse> search(Long subjectId, Statut statut);

  /**
   * Crée une nouvelle tâche pour l'utilisateur connecté.
   */
  TaskResponse create(TaskRequest request);

  /**
   * Met à jour une tâche existante.
   */
  TaskResponse update(Long id, TaskRequest request);

  /**
   * Supprime une tâche de l'utilisateur connecté.
   */
  void delete(Long id);

  /**
   * Calcule et retourne les métriques pour le tableau de bord de l'utilisateur.
   */
  DashboardResponse dashboard();
}
