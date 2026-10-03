package sn.campustasks.api;

import sn.campustasks.api.dto.Dtos.*;
import sn.campustasks.service.SubjectService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur REST de gestion des matières académiques.
 * Toutes les opérations sont sécurisées et cloisonnées par utilisateur authentifié.
 */
@RestController
@RequestMapping("/api/v1/subjects")
public class SubjectController {

  private final SubjectService service;

  public SubjectController(SubjectService service) {
    this.service = service;
  }

  /**
   * Récupère la liste de toutes les matières de l'utilisateur connecté.
   *
   * @return Liste ordonnée des matières
   */
  @GetMapping
  public List<SubjectResponse> list() {
    return service.list();
  }

  /**
   * Crée une nouvelle matière pour l'étudiant.
   *
   * @param request Corps contenant le nom et la description de la matière
   * @return La matière créée (HTTP 201 Created)
   */
  @PostMapping
  public ResponseEntity<SubjectResponse> create(@Valid @RequestBody SubjectRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
  }

  /**
   * Modifie une matière existante appartenant à l'étudiant.
   *
   * @param id Identifiant de la matière
   * @param request Nouvelles informations de la matière
   * @return La matière mise à jour
   */
  @PutMapping("/{id}")
  public SubjectResponse update(@PathVariable Long id, @Valid @RequestBody SubjectRequest request) {
    return service.update(id, request);
  }

  /**
   * Supprime une matière.
   *
   * @param id Identifiant de la matière
   * @param force Si true, supprime la matière et ses tâches associées en cascade
   * @return HTTP 204 No Content
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> delete(
      @PathVariable Long id,
      @RequestParam(defaultValue = "false") boolean force
  ) {
    service.delete(id, force);
    return ResponseEntity.noContent().build();
  }
}
