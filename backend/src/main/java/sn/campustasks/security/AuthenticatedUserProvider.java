package sn.campustasks.security;
import sn.campustasks.domain.entity.User; import sn.campustasks.repository.UserRepository; import org.springframework.security.core.context.SecurityContextHolder; import org.springframework.stereotype.Component;
@Component public class AuthenticatedUserProvider {
 private final UserRepository repo; public AuthenticatedUserProvider(UserRepository repo){this.repo=repo;}
 public User get(){String email=SecurityContextHolder.getContext().getAuthentication().getName();return repo.findByEmailIgnoreCase(email).orElseThrow(()->new RuntimeException("Utilisateur introuvable"));}
 public Long id(){return get().getId();}
}
