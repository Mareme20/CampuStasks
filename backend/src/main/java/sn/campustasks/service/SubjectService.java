package sn.campustasks.service;
import sn.campustasks.api.dto.Dtos.*; import sn.campustasks.domain.entity.*; import sn.campustasks.exception.ApiExceptions.*; import sn.campustasks.repository.*; import sn.campustasks.security.AuthenticatedUserProvider; import org.springframework.stereotype.Service; import java.util.*;
@Service public class SubjectService {
 private final SubjectRepository repo; private final AuthenticatedUserProvider auth;
 public SubjectService(SubjectRepository r,AuthenticatedUserProvider a){repo=r;auth=a;}
 public List<SubjectResponse> list(){return repo.findAllByOwnerIdOrderByNomAsc(auth.id()).stream().map(this::dto).toList();}
 public SubjectResponse create(SubjectRequest r){return dto(repo.save(Subject.builder().nom(r.nom().trim()).description(r.description()).owner(auth.get()).build()));}
 public SubjectResponse update(Long id,SubjectRequest r){Subject s=get(id);s.setNom(r.nom().trim());s.setDescription(r.description());return dto(repo.save(s));}
 public void delete(Long id,boolean force){Subject s=get(id);long n=repo.countTasks(id);if(n>0&&!force)throw new ConflictException("La matière contient des tâches. Utilisez force=true pour supprimer la matière et ses tâches.");repo.delete(s);}
 private Subject get(Long id){return repo.findByIdAndOwnerId(id,auth.id()).orElseThrow(()->new ResourceNotFoundException("Matière introuvable."));}
 private SubjectResponse dto(Subject s){return new SubjectResponse(s.getId(),s.getNom(),s.getDescription(),s.getDateCreation(),repo.countTasks(s.getId()));}
}
