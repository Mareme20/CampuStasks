package sn.campustasks.exception;
public final class ApiExceptions {
 private ApiExceptions(){}
 public static class ResourceNotFoundException extends RuntimeException{public ResourceNotFoundException(String m){super(m);}}
 public static class BadRequestException extends RuntimeException{public BadRequestException(String m){super(m);}}
 public static class ConflictException extends RuntimeException{public ConflictException(String m){super(m);}}
}
