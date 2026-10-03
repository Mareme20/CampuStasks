package sn.campustasks.security;

import sn.campustasks.domain.entity.User;
import sn.campustasks.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Service d'intégration avec Spring Security pour charger les détails d'un utilisateur.
 * Utilisé lors de la vérification de l'identité par token JWT.
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

  private final UserRepository repo;

  public UserDetailsServiceImpl(UserRepository repo) {
    this.repo = repo;
  }

  /**
   * Charge un utilisateur par son identifiant unique (ici son adresse e-mail).
   *
   * @param email L'adresse e-mail de l'utilisateur
   * @return Un objet {@link UserDetails} exploitable par Spring Security
   * @throws UsernameNotFoundException si l'utilisateur n'existe pas en base
   */
  @Override
  public UserDetails loadUserByUsername(String email) {
    User u = repo.findByEmailIgnoreCase(email)
        .orElseThrow(() -> new UsernameNotFoundException("Utilisateur introuvable"));

    return org.springframework.security.core.userdetails.User
        .withUsername(u.getEmail())
        .password(u.getPasswordHash())
        .roles("STUDENT")
        .build();
  }
}
