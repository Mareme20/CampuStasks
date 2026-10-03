package sn.campustasks.service;
import sn.campustasks.api.dto.Dtos.*; import sn.campustasks.domain.entity.User; import sn.campustasks.exception.ApiExceptions.*; import sn.campustasks.repository.UserRepository; import sn.campustasks.security.JwtService; import org.springframework.security.crypto.password.PasswordEncoder; import org.springframework.stereotype.Service;
@Service public class AuthService {
 private final UserRepository users; private final PasswordEncoder encoder; private final JwtService jwt;
 public AuthService(UserRepository u,PasswordEncoder e,JwtService j){users=u;encoder=e;jwt=j;}
 public AuthResponse register(RegisterRequest r){if(users.existsByEmailIgnoreCase(r.email()))throw new ConflictException("Cette adresse e-mail est déjà utilisée.");User u=User.builder().nom(r.nom().trim()).email(r.email().trim().toLowerCase()).passwordHash(encoder.encode(r.password())).build();users.save(u);return new AuthResponse(jwt.generate(u.getId(),u.getEmail()),u.getId(),u.getNom(),u.getEmail());}
 public AuthResponse login(LoginRequest r){User u=users.findByEmailIgnoreCase(r.email()).orElseThrow(()->new BadRequestException("E-mail ou mot de passe incorrect."));if(!encoder.matches(r.password(),u.getPasswordHash()))throw new BadRequestException("E-mail ou mot de passe incorrect.");return new AuthResponse(jwt.generate(u.getId(),u.getEmail()),u.getId(),u.getNom(),u.getEmail());}
}
