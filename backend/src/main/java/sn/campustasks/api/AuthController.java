package sn.campustasks.api;

import sn.campustasks.api.dto.Dtos.*;
import sn.campustasks.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Contrôleur REST pour l'authentification et l'inscription des étudiants.
 * Il expose les points de terminaison publics permettant d'obtenir un jeton JWT.
 */
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

  private final AuthService service;

  public AuthController(AuthService service) {
    this.service = service;
  }

  /**
   * Endpoint d'inscription d'un nouvel étudiant.
   *
   * @param request Corps contenant le nom, l'email et le mot de passe
   * @return Les données de l'utilisateur avec son token JWT (HTTP 201 Created)
   */
  @PostMapping("/register")
  public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(service.register(request));
  }

  /**
   * Endpoint de connexion d'un étudiant existant.
   *
   * @param request Corps contenant l'email et le mot de passe
   * @return Les données de l'utilisateur avec son token JWT (HTTP 200 OK)
   */
  @PostMapping("/login")
  public AuthResponse login(@Valid @RequestBody LoginRequest request) {
    return service.login(request);
  }
}
