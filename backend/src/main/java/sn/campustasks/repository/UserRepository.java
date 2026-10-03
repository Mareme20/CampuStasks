package sn.campustasks.repository;

import sn.campustasks.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

/**
 * Interface d'accès aux données (Spring Data JPA) pour les utilisateurs.
 */
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Recherche un utilisateur par son adresse e-mail (insensible à la casse).
     * Utilisé lors de la connexion.
     *
     * @param email Adresse e-mail recherchée
     * @return Optional contenant l'utilisateur s'il existe
     */
    Optional<User> findByEmailIgnoreCase(String email);

    /**
     * Vérifie si un compte existe déjà avec cette adresse e-mail.
     * Utilisé pour éviter les doublons lors de l'inscription.
     *
     * @param email Adresse e-mail à vérifier
     * @return true si l'e-mail est déjà pris, false sinon
     */
    boolean existsByEmailIgnoreCase(String email);
}
