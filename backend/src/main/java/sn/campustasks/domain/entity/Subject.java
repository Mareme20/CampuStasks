package sn.campustasks.domain.entity;
import jakarta.persistence.*; import lombok.*; import java.util.*;
@Entity @Table(name="subjects") @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Subject extends BaseEntity {
 @Column(nullable=false,length=120) private String nom;
 @Column(length=500) private String description;
 @ManyToOne(fetch=FetchType.LAZY,optional=false) @JoinColumn(name="owner_id",nullable=false) private User owner;
 @OneToMany(mappedBy="subject",cascade=CascadeType.ALL,orphanRemoval=true) @Builder.Default private List<Task> tasks=new ArrayList<>();
}
