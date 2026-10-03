package sn.campustasks.api;
import sn.campustasks.api.dto.Dtos.*; import sn.campustasks.domain.enums.Statut; import sn.campustasks.service.TaskService; import jakarta.validation.Valid; import org.springframework.http.*; import org.springframework.web.bind.annotation.*; import java.util.*;
@RestController @RequestMapping("/api/v1/tasks") public class TaskController {
 private final TaskService service; public TaskController(TaskService s){service=s;}
 @GetMapping List<TaskResponse> list(@RequestParam(required=false)Long subjectId,@RequestParam(required=false)Statut statut){return service.search(subjectId,statut);}
 @PostMapping ResponseEntity<TaskResponse> create(@Valid @RequestBody TaskRequest r){return ResponseEntity.status(HttpStatus.CREATED).body(service.create(r));}
 @PutMapping("/{id}") TaskResponse update(@PathVariable Long id,@Valid @RequestBody TaskRequest r){return service.update(id,r);}
 @DeleteMapping("/{id}") ResponseEntity<Void> delete(@PathVariable Long id){service.delete(id);return ResponseEntity.noContent().build();}
}
