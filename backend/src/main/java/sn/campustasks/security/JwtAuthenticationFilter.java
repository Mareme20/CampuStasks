package sn.campustasks.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filtre de sécurité interceptant chaque requête HTTP une seule fois (OncePerRequestFilter).
 * Il lit l'en-tête "Authorization: Bearer <token>", valide l'intégrité et l'expiration du JWT,
 * et peuple le contexte de sécurité Spring Security avec l'utilisateur authentifié.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private final JwtService jwt;
  private final UserDetailsServiceImpl users;

  public JwtAuthenticationFilter(JwtService jwt, UserDetailsServiceImpl users) {
    this.jwt = jwt;
    this.users = users;
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest req,
      HttpServletResponse res,
      FilterChain chain
  ) throws ServletException, IOException {

    String header = req.getHeader("Authorization");

    // Vérifie la présence du schéma Bearer dans le header Authorization
    if (header != null && header.startsWith("Bearer ")) {
      String token = header.substring(7);

      // Si le token est valide, extrait le sujet (email) et initialise l'authentification Spring
      if (jwt.valid(token)) {
        String email = jwt.email(token);
        UserDetails userDetails = users.loadUserByUsername(email);

        UsernamePasswordAuthenticationToken authentication =
            new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

        SecurityContextHolder.getContext().setAuthentication(authentication);
      }
    }

    // Poursuit la chaîne d'exécution des filtres
    chain.doFilter(req, res);
  }
}
