package sn.campustasks.exception;

/**
 * Conteneur des exceptions métier personnalisées levées par la couche service
 * et interceptées par {@link GlobalExceptionHandler}.
 */
public final class ApiExceptions {

  private ApiExceptions() {}

  /**
   * Exception levée lorsqu'une ressource demandée (tâche, matière, utilisateur) n'existe pas
   * ou n'appartient pas à l'utilisateur connecté (Code HTTP 404 Not Found).
   */
  public static class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
      super(message);
    }
  }

  /**
   * Exception levée lors d'une requête invalide, identifiants erronés ou paramètres incorrects
   * (Code HTTP 400 Bad Request).
   */
  public static class BadRequestException extends RuntimeException {
    public BadRequestException(String message) {
      super(message);
    }
  }

  /**
   * Exception levée lors d'un conflit d'état, par exemple un e-mail déjà utilisé
   * ou la suppression d'une matière ayant des tâches sans l'option force
   * (Code HTTP 409 Conflict).
   */
  public static class ConflictException extends RuntimeException {
    public ConflictException(String message) {
      super(message);
    }
  }
}
