package sn.campustasks.api;

import sn.campustasks.api.dto.Dtos.DashboardResponse;
import sn.campustasks.service.TaskService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Contrôleur REST pour le tableau de bord de l'application.
 * Fournit les compteurs statistiques (tâches à faire, en cours, terminées,
 * en retard et prochaines échéances) pour l'étudiant connecté.
 */
@RestController
@RequestMapping("/api/v1/dashboard")
public class DashboardController {

  private final TaskService service;

  public DashboardController(TaskService service) {
    this.service = service;
  }

  /**
   * Retourne l'ensemble des indicateurs de synthèse du tableau de bord.
   *
   * @return DashboardResponse consolidé
   */
  @GetMapping
  public DashboardResponse get() {
    return service.dashboard();
  }
}
