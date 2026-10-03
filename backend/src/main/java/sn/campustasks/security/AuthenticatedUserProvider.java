package sn.campustasks.security;

import sn.campustasks.domain.entity.User;
import sn.campustasks.exception.ApiExceptions.ResourceNotFoundException;
import sn.campustasks.repository.UserRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

/**
 * Composant d'assistance pour récupérer l'utilisateur actuellement authentifié.
 * Il extrait le nom d'utilisateur (e-mail) depuis le SecurityContext de Spring Security
 * et charge l'entité correspondante en base de données.
 */
@Component
public class AuthenticatedUserProvider {

  private final UserRepository repo;

  public AuthenticatedUserProvider(UserRepository repo) {
    this.repo = repo;
  }

  /**
   * Retourne l'entité {@link User} complète de l'utilisateur authentifié pour la requête courante.
   *
   * @return L'utilisateur connecté
   * @throws ResourceNotFoundException si l'utilisateur est introuvable
   */
  public User get() {
    String email = SecurityContextHolder.getContext().getAuthentication().getName();
    return repo.findByEmailIgnoreCase(email)
        .orElseThrow(() -> new ResourceNotFoundException("Utilisateur authentifié introuvable"));
  }

  /**
   * Retourne l'identifiant technique (ID) de l'utilisateur authentifié.
   *
   * @return Long id de l'utilisateur
   */
  public Long id() {
    return get().getId();
  }
}
