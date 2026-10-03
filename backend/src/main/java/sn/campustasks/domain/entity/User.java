package sn.campustasks.domain.entity;
import jakarta.persistence.*; import lombok.*; import java.util.*;
@Entity @Table(name="users",uniqueConstraints=@UniqueConstraint(name="uk_user_email",columnNames="email"))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User extends BaseEntity {
 @Column(nullable=false,length=120) private String nom;
 @Column(nullable=false,length=180) private String email;
 @Column(nullable=false,length=100) private String passwordHash;
 @OneToMany(mappedBy="owner",cascade=CascadeType.ALL,orphanRemoval=true) @Builder.Default private List<Subject> subjects=new ArrayList<>();
}
