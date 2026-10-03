package sn.campustasks.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Service JWT de l'API CampusTasks.
 * Il signe cryptographiquement les JSON Web Tokens (HMAC-SHA), valide leur intégrité
 * et extrait l'identité de l'utilisateur pour sécuriser les routes protégées.
 */
@Service
public class JwtService {
    private final SecretKey key;
    private final long expiration;

    public JwtService(
        @Value("${app.jwt.secret}") String secret,
        @Value("${app.jwt.expiration-ms}") long expiration
    ) {
        if (secret.length() < 32) {
            throw new IllegalArgumentException("JWT_SECRET doit contenir au moins 32 caractères.");
        }
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expiration = expiration;
    }

    /**
     * Génère un token JWT signé contenant l'ID et l'e-mail de l'utilisateur.
     *
     * @param id Identifiant de l'utilisateur
     * @param email Adresse e-mail servant de subject
     * @return Chaîne compacte représentant le JWT signé
     */
    public String generate(Long id, String email) {
        Date now = new Date();
        return Jwts.builder()
            .subject(email)
            .claim("userId", id)
            .issuedAt(now)
            .expiration(new Date(now.getTime() + expiration))
            .signWith(key)
            .compact();
    }

    /**
     * Extrait l'adresse e-mail (subject) contenue dans le token après vérification de sa signature.
     *
     * @param token Le token JWT
     * @return L'e-mail du porteur du token
     */
    public String email(String token) {
        return Jwts.parser()
            .verifyWith(key)
            .build()
            .parseSignedClaims(token)
            .getPayload()
            .getSubject();
    }

    /**
     * Valide l'intégrité et la validité temporelle du token.
     *
     * @param token Le token JWT à vérifier
     * @return true si le token est valide et non expiré, false sinon
     */
    public boolean valid(String token) {
        try {
            email(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
