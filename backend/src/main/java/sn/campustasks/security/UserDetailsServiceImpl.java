package sn.campustasks.security;
import sn.campustasks.repository.UserRepository; import org.springframework.security.core.userdetails.*; import org.springframework.stereotype.Service;
@Service public class UserDetailsServiceImpl implements UserDetailsService {
 private final UserRepository repo; public UserDetailsServiceImpl(UserRepository repo){this.repo=repo;}
 public UserDetails loadUserByUsername(String email){var u=repo.findByEmailIgnoreCase(email).orElseThrow(()->new UsernameNotFoundException("Utilisateur introuvable"));return User.withUsername(u.getEmail()).password(u.getPasswordHash()).roles("STUDENT").build();}
}
