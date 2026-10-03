package sn.campustasks.api;

import sn.campustasks.api.dto.Dtos.*;
import sn.campustasks.domain.enums.Statut;
import sn.campustasks.service.TaskService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur REST de gestion des tâches étudiantes.
 * Permet de rechercher, filtrer, créer, modifier et supprimer les tâches
 * associées à l'utilisateur connecté.
 */
@RestController
@RequestMapping("/api/v1/tasks")
public class TaskController {

  private final TaskService service;

  public TaskController(TaskService service) {
    this.service = service;
  }

  /**
   * Liste et filtre les tâches de l'utilisateur.
   *
   * @param subjectId Filtre optionnel par matière
   * @param statut Filtre optionnel par statut (A_FAIRE, EN_COURS, TERMINEE)
   * @return Liste des tâches correspondantes
   */
  @GetMapping
  public List<TaskResponse> list(
      @RequestParam(required = false) Long subjectId,
      @RequestParam(required = false) Statut statut
  ) {
    return service.search(subjectId, statut);
  }

  /**
   * Crée une nouvelle tâche pour l'utilisateur connecté.
   *
   * @param request Corps contenant les informations de la tâche
   * @return La tâche créée (HTTP 201 Created)
   */
  @PostMapping
  public ResponseEntity<TaskResponse> create(@Valid @RequestBody TaskRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
  }

  /**
   * Modifie une tâche existante.
   *
   * @param id Identifiant de la tâche à modifier
   * @param request Nouvelles données de la tâche
   * @return La tâche mise à jour
   */
  @PutMapping("/{id}")
  public TaskResponse update(
      @PathVariable Long id,
      @Valid @RequestBody TaskRequest request
  ) {
    return service.update(id, request);
  }

  /**
   * Supprime une tâche appartenant à l'utilisateur.
   *
   * @param id Identifiant de la tâche
   * @return HTTP 204 No Content
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> delete(@PathVariable Long id) {
    service.delete(id);
    return ResponseEntity.noContent().build();
  }
}
