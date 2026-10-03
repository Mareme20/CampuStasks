package sn.campustasks.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.stream.Collectors;

/**
 * Gestionnaire d'exceptions global pour l'API REST.
 * Intercepte les erreurs métier et techniques afin de produire des réponses HTTP
 * standardisées et prévisibles (contenant horodatage, code HTTP, statut et message explicatif).
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

  /**
   * Structure de réponse d'erreur unifiée envoyée aux clients (Mobile / Web).
   */
  public record ErrorResponse(
      Instant timestamp,
      int status,
      String error,
      String message
  ) {}

  /**
   * Traitement des erreurs 404 (ressource introuvable).
   */
  @ExceptionHandler(ApiExceptions.ResourceNotFoundException.class)
  public ResponseEntity<ErrorResponse> handleNotFound(RuntimeException ex) {
    return buildResponse(HttpStatus.NOT_FOUND, ex.getMessage());
  }

  /**
   * Traitement des erreurs 409 (conflit de ressource, duplication d'e-mail, dépendances).
   */
  @ExceptionHandler(ApiExceptions.ConflictException.class)
  public ResponseEntity<ErrorResponse> handleConflict(RuntimeException ex) {
    return buildResponse(HttpStatus.CONFLICT, ex.getMessage());
  }

  /**
   * Traitement des erreurs 400 (requêtes invalides ou violations de validation de champs).
   */
  @ExceptionHandler({
      ApiExceptions.BadRequestException.class,
      MethodArgumentNotValidException.class
  })
  public ResponseEntity<ErrorResponse> handleBadRequest(Exception ex) {
    String message;
    if (ex instanceof MethodArgumentNotValidException validationEx) {
      // Regroupe les messages d'erreurs de chaque champ non valide
      message = validationEx.getBindingResult().getFieldErrors().stream()
          .map(err -> err.getField() + ": " + err.getDefaultMessage())
          .collect(Collectors.joining(", "));
    } else {
      message = ex.getMessage();
    }
    return buildResponse(HttpStatus.BAD_REQUEST, message);
  }

  /**
   * Méthode utilitaire de construction de la réponse d'erreur standardisée.
   */
  private ResponseEntity<ErrorResponse> buildResponse(HttpStatus status, String message) {
    return ResponseEntity
        .status(status)
        .body(new ErrorResponse(Instant.now(), status.value(), status.getReasonPhrase(), message));
  }
}
