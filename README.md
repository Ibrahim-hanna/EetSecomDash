# EetSecomDash - Dashboard de Gestion de Projets

## Description

EetSecomDash est une application web Spring Boot qui permet la gestion de projets avec un système d'authentification et de rôles. L'application offre un dashboard interactif pour les administrateurs, superviseurs et employés.

## Fonctionnalités

- **Authentification JWT** : Système de connexion sécurisé avec tokens JWT
- **Gestion des rôles** : Administrateur, Superviseur, Employé
- **Gestion de projets** : CRUD complet pour les projets
- **Upload de fichiers** : Système de pièces jointes pour les projets
- **Dashboard interactif** : Interface web moderne avec WebSocket
- **API REST** : Endpoints pour l'intégration avec d'autres applications

## Technologies utilisées

- **Backend** : Spring Boot 3.x
- **Base de données** : H2 (développement) / MySQL (production)
- **Sécurité** : Spring Security + JWT
- **Frontend** : HTML, CSS, JavaScript
- **WebSocket** : Pour les mises à jour en temps réel
- **Build** : Maven

## Structure du projet

```
src/
├── main/
│   ├── java/com/example/Springboot/
│   │   ├── config/          # Configuration Spring
│   │   ├── controller/      # Contrôleurs REST
│   │   ├── dto/            # Objets de transfert de données
│   │   ├── model/          # Entités JPA
│   │   ├── repository/     # Repositories Spring Data
│   │   ├── service/        # Services métier
│   │   └── SpringbootApplication.java
│   └── resources/
│       ├── static/         # Fichiers statiques (HTML, CSS, JS)
│       ├── templates/      # Templates Thymeleaf
│       └── application.properties
```

## Installation et démarrage

### Prérequis

- Java 17 ou supérieur
- Maven 3.6+
- Git

### Étapes d'installation

1. **Cloner le repository**
   ```bash
   git clone https://github.com/votre-username/EetSecomDash.git
   cd EetSecomDash
   ```

2. **Compiler le projet**
   ```bash
   mvn clean install
   ```

3. **Lancer l'application**
   ```bash
   mvn spring-boot:run
   ```

4. **Accéder à l'application**
   - URL : http://localhost:8080
   - Dashboard : http://localhost:8080/dashboard

## Configuration

### Base de données

L'application utilise H2 en mode développement. Pour la production, configurez MySQL dans `application.properties` :

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/eetsecomdash
spring.datasource.username=votre_username
spring.datasource.password=votre_password
```

### JWT Configuration

Modifiez les propriétés JWT dans `application.properties` :

```properties
jwt.secret=votre_secret_jwt_tres_long_et_complexe
jwt.expiration=86400000
```

## API Endpoints

### Authentification
- `POST /api/auth/login` - Connexion
- `POST /api/auth/register` - Inscription
- `POST /api/auth/logout` - Déconnexion

### Projets
- `GET /api/projets` - Liste des projets
- `POST /api/projets` - Créer un projet
- `PUT /api/projets/{id}` - Modifier un projet
- `DELETE /api/projets/{id}` - Supprimer un projet

### Utilisateurs
- `GET /api/users` - Liste des utilisateurs
- `POST /api/users` - Créer un utilisateur
- `PUT /api/users/{id}` - Modifier un utilisateur

## Rôles et permissions

- **ADMIN** : Accès complet à toutes les fonctionnalités
- **SUPERVISEUR** : Gestion des projets et équipes
- **EMPLOYE** : Consultation et mise à jour des projets assignés

## Développement

### Ajouter une nouvelle fonctionnalité

1. Créer l'entité dans `model/`
2. Créer le repository dans `repository/`
3. Créer le service dans `service/`
4. Créer le contrôleur dans `controller/`
5. Ajouter les tests unitaires

### Tests

```bash
# Lancer tous les tests
mvn test

# Lancer les tests avec couverture
mvn jacoco:report
```

## Déploiement

### Docker

```bash
# Construire l'image
docker build -t eetsecomdash .

# Lancer le conteneur
docker run -p 8080:8080 eetsecomdash
```

### Production

1. Configurer la base de données MySQL
2. Modifier `application.properties` pour la production
3. Construire le JAR : `mvn clean package`
4. Déployer le JAR sur votre serveur

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement

## Changelog

### Version 1.0.0
- Système d'authentification JWT
- Gestion des projets CRUD
- Dashboard interactif
- Upload de fichiers
- Gestion des rôles et permissions 