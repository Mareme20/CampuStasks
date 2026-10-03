package sn.campustasks.service;

import sn.campustasks.api.dto.Dtos.AuthResponse;
import sn.campustasks.api.dto.Dtos.LoginRequest;
import sn.campustasks.api.dto.Dtos.RegisterRequest;

/**
 * Interface du service central d'authentification.
 * Définit le contrat métier pour l'inscription et la connexion.
 */
public interface AuthService {

  /**
   * Inscrit un nouvel utilisateur et retourne son token JWT.
   */
  AuthResponse register(RegisterRequest request);

  /**
   * Authentifie un utilisateur existant et retourne son token JWT.
   */
  AuthResponse login(LoginRequest request);
}
