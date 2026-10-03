package sn.campustasks.api;
import sn.campustasks.api.dto.Dtos.*; import sn.campustasks.service.SubjectService; import jakarta.validation.Valid; import org.springframework.http.*; import org.springframework.web.bind.annotation.*; import java.util.*;
@RestController @RequestMapping("/api/v1/subjects") public class SubjectController {
 private final SubjectService service; public SubjectController(SubjectService s){service=s;}
 @GetMapping List<SubjectResponse> list(){return service.list();}
 @PostMapping ResponseEntity<SubjectResponse> create(@Valid @RequestBody SubjectRequest r){return ResponseEntity.status(HttpStatus.CREATED).body(service.create(r));}
 @PutMapping("/{id}") SubjectResponse update(@PathVariable Long id,@Valid @RequestBody SubjectRequest r){return service.update(id,r);}
 @DeleteMapping("/{id}") ResponseEntity<Void> delete(@PathVariable Long id,@RequestParam(defaultValue="false")boolean force){service.delete(id,force);return ResponseEntity.noContent().build();}
}
