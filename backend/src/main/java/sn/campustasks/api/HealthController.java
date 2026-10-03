package sn.campustasks.api;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Contrôleur minimal de santé pour les vérifications de disponibilité.
 * Expose `/health` et `/api/v1/health` pour les probes et le reverse-proxy.
 */
@RestController
@RequestMapping
public class HealthController {

  @GetMapping("/health")
  public ResponseEntity<String> healthRoot() {
    return ResponseEntity.ok("ok");
  }

  @GetMapping("/api/v1/health")
  public ResponseEntity<String> healthApi() {
    return ResponseEntity.ok("ok");
  }
}
