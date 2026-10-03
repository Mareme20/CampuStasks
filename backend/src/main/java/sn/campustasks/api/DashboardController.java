package sn.campustasks.api;
import sn.campustasks.api.dto.Dtos.DashboardResponse; import sn.campustasks.service.TaskService; import org.springframework.web.bind.annotation.*;
@RestController @RequestMapping("/api/v1/dashboard") public class DashboardController {
 private final TaskService service; public DashboardController(TaskService s){service=s;}
 @GetMapping DashboardResponse get(){return service.dashboard();}
}
