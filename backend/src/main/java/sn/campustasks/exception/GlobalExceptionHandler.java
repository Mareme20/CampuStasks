package sn.campustasks.exception;
import org.springframework.http.*; import org.springframework.web.bind.MethodArgumentNotValidException; import org.springframework.web.bind.annotation.*; import java.time.Instant; import java.util.stream.Collectors;
@RestControllerAdvice
public class GlobalExceptionHandler {
 record ErrorResponse(Instant timestamp,int status,String error,String message){}
 @ExceptionHandler(ApiExceptions.ResourceNotFoundException.class) ResponseEntity<ErrorResponse> nf(RuntimeException e){return build(HttpStatus.NOT_FOUND,e.getMessage());}
 @ExceptionHandler(ApiExceptions.ConflictException.class) ResponseEntity<ErrorResponse> cf(RuntimeException e){return build(HttpStatus.CONFLICT,e.getMessage());}
 @ExceptionHandler({ApiExceptions.BadRequestException.class,MethodArgumentNotValidException.class}) ResponseEntity<ErrorResponse> br(Exception e){
   String m=e instanceof MethodArgumentNotValidException v?v.getBindingResult().getFieldErrors().stream().map(x->x.getField()+": "+x.getDefaultMessage()).collect(Collectors.joining(", ")):e.getMessage();
   return build(HttpStatus.BAD_REQUEST,m);
 }
 private ResponseEntity<ErrorResponse> build(HttpStatus s,String m){return ResponseEntity.status(s).body(new ErrorResponse(Instant.now(),s.value(),s.getReasonPhrase(),m));}
}
