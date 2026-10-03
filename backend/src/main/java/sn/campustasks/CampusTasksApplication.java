package sn.campustasks;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Point d'entrée principal de l'API CampusTasks.
 * Spring Boot initialise ici le contexte applicatif, la sécurité,
 * l'accès aux données et les contrôleurs REST.
 */
@SpringBootApplication
public class CampusTasksApplication {
  public static void main(String[] args) {
    SpringApplication.run(CampusTasksApplication.class, args);
  }
}
