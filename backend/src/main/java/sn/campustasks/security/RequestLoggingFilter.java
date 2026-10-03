package sn.campustasks.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

/**
 * Filtre de diagnostic minimal qui loggue les requêtes entrantes et l'authentification
 * présente dans le SecurityContext afin d'identifier pourquoi une requête reçoit 403.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestLoggingFilter extends OncePerRequestFilter {

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
      throws ServletException, IOException {
    try {
      System.out.println("[RequestLoggingFilter] " + request.getMethod() + " " + request.getRequestURI());
      var auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
      System.out.println("[RequestLoggingFilter] Authentication: " + (auth == null ? "<null>" : auth.getName() + " / " + auth.getAuthorities()));
      var headers = Collections.list(request.getHeaderNames());
      System.out.println("[RequestLoggingFilter] Headers: " + headers);
    } catch (Exception e) {
      System.out.println("[RequestLoggingFilter] Error while logging request: " + e.getMessage());
    }

    filterChain.doFilter(request, response);

    // Log status after chain
    System.out.println("[RequestLoggingFilter] Response status for " + request.getRequestURI() + " -> " + response.getStatus());
  }
}
