package sn.campustasks.service.impl;

import sn.campustasks.api.dto.Dtos.*;
import sn.campustasks.domain.entity.*;
import sn.campustasks.domain.enums.Statut;
import sn.campustasks.exception.ApiExceptions.*;
import sn.campustasks.repository.*;
import sn.campustasks.security.AuthenticatedUserProvider;
import sn.campustasks.service.TaskService;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Implémentation concrète du service métier de gestion des tâches.
 * Il applique les règles d'accès par utilisateur, sécurise les opérations
 * sur les matières et prépare les données pour le tableau de bord.
 */
@Service
public class TaskServiceImpl implements TaskService {
  private final TaskRepository tasks;
  private final SubjectRepository subjects;
  private final AuthenticatedUserProvider auth;

  public TaskServiceImpl(TaskRepository t, SubjectRepository s, AuthenticatedUserProvider a) {
    tasks = t;
    subjects = s;
    auth = a;
  }

  @Override
  public List<TaskResponse> search(Long subjectId, Statut statut) {
    if (subjectId != null && !subjects.existsByIdAndOwnerId(subjectId, auth.id())) {
      throw new ResourceNotFoundException("Matière introuvable.");
    }
    return tasks.search(auth.id(), subjectId, statut).stream().map(this::dto).toList();
  }

  @Override
  public TaskResponse create(TaskRequest r) {
    Subject s = subject(r.subjectId());
    Task t = Task.builder()
        .titre(r.titre().trim())
        .description(r.description())
        .dateLimite(r.dateLimite())
        .priorite(r.priorite())
        .statut(r.statut())
        .subject(s)
        .owner(auth.get())
        .build();
    return dto(tasks.save(t));
  }

  @Override
  public TaskResponse update(Long id, TaskRequest r) {
    Task t = get(id);
    t.setTitre(r.titre().trim());
    t.setDescription(r.description());
    t.setDateLimite(r.dateLimite());
    t.setPriorite(r.priorite());
    t.setStatut(r.statut());
    t.setSubject(subject(r.subjectId()));
    return dto(tasks.save(t));
  }

  @Override
  public void delete(Long id) {
    tasks.delete(get(id));
  }

  @Override
  public DashboardResponse dashboard() {
    Long id = auth.id();
    LocalDateTime now = LocalDateTime.now();
    return new DashboardResponse(
        tasks.countByOwnerIdAndStatut(id, Statut.A_FAIRE),
        tasks.countByOwnerIdAndStatut(id, Statut.EN_COURS),
        tasks.countByOwnerIdAndStatut(id, Statut.TERMINEE),
        tasks.findUpcoming(id, Statut.TERMINEE, now).stream().limit(5).map(this::dto).toList(),
        tasks.findLate(id, Statut.TERMINEE, now).stream().map(this::dto).toList());
  }

  private Subject subject(Long id) {
    return subjects.findByIdAndOwnerId(id, auth.id())
        .orElseThrow(() -> new ResourceNotFoundException("Matière introuvable."));
  }

  private Task get(Long id) {
    return tasks.findByIdAndOwnerId(id, auth.id())
        .orElseThrow(() -> new ResourceNotFoundException("Tâche introuvable."));
  }

  private TaskResponse dto(Task t) {
    return new TaskResponse(
        t.getId(),
        t.getTitre(),
        t.getDescription(),
        t.getSubject().getId(),
        t.getSubject().getNom(),
        t.getDateLimite(),
        t.getPriorite(),
        t.getStatut(),
        t.getDateCreation());
  }
}
