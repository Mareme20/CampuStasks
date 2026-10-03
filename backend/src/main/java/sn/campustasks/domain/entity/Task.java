package sn.campustasks.domain.entity;
import sn.campustasks.domain.enums.*; import jakarta.persistence.*; import lombok.*; import java.time.LocalDateTime;
@Entity @Table(name="tasks",indexes={@Index(name="idx_task_owner_due",columnList="owner_id,date_limite")})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Task extends BaseEntity {
 @Column(nullable=false,length=180) private String titre;
 @Column(length=2000) private String description;
 @Column(name="date_limite",nullable=false) private LocalDateTime dateLimite;
 @Enumerated(EnumType.STRING) @Column(nullable=false,length=20) private Priorite priorite;
 @Enumerated(EnumType.STRING) @Column(nullable=false,length=20) private Statut statut;
 @ManyToOne(fetch=FetchType.LAZY,optional=false) @JoinColumn(name="subject_id",nullable=false) private Subject subject;
 @ManyToOne(fetch=FetchType.LAZY,optional=false) @JoinColumn(name="owner_id",nullable=false) private User owner;
}
