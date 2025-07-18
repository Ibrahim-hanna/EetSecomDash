# Guide de Déploiement EetSecomDash en Entreprise

## Vue d'ensemble

Ce guide vous accompagne pour déployer l'application EetSecomDash dans votre environnement d'entreprise.

## Options de déploiement

### Option 1: Déploiement JAR (Recommandé pour débuter)

**Avantages:**
- Simple à mettre en place
- Pas besoin de Docker
- Facile à maintenir

**Prérequis:**
- Java 17 ou supérieur
- MySQL 8.0 ou supérieur
- Maven 3.6+

**Étapes:**

1. **Préparer l'environnement**
   ```bash
   # Installer Java 17
   # Installer MySQL
   # Installer Maven
   ```

2. **Configurer la base de données**
   ```sql
   CREATE DATABASE eetsecomdash;
   CREATE USER 'eetsecom'@'localhost' IDENTIFIED BY 'votre_mot_de_passe';
   GRANT ALL PRIVILEGES ON eetsecomdash.* TO 'eetsecom'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Déployer l'application**
   ```bash
   # Exécuter le script de déploiement
   deploy-enterprise.bat
   ```

4. **Configurer les variables d'environnement**
   - Modifier `deploy/application.properties`
   - Ajuster les paramètres de base de données
   - Changer les secrets JWT

5. **Démarrer l'application**
   ```bash
   cd deploy
   start-enterprise.bat
   ```

### Option 2: Déploiement Docker (Recommandé pour production)

**Avantages:**
- Environnement isolé
- Facile à déployer
- Reproducible
- Gestion automatique des dépendances

**Prérequis:**
- Docker Desktop
- Docker Compose

**Étapes:**

1. **Installer Docker Desktop**
   - Télécharger depuis https://www.docker.com/products/docker-desktop
   - Démarrer Docker Desktop

2. **Déployer avec Docker**
   ```bash
   deploy-docker.bat
   ```

3. **Accéder à l'application**
   - URL: http://localhost:8080
   - Base de données: localhost:3306

### Option 3: Déploiement sur serveur d'application

**Pour Tomcat, JBoss, WebSphere, etc.**

1. **Générer le WAR**
   ```bash
   mvn clean package -Pwar
   ```

2. **Déployer le WAR**
   - Copier le fichier WAR dans le répertoire de déploiement
   - Configurer la base de données
   - Redémarrer le serveur

## Configuration de production

### Variables d'environnement importantes

```properties
# Base de données
DB_USERNAME=eetsecom
DB_PASSWORD=votre_mot_de_passe_securise

# JWT
JWT_SECRET=votre_secret_jwt_tres_long_et_complexe

# Admin
ADMIN_USERNAME=admin
ADMIN_PASSWORD=mot_de_passe_admin_securise

# Serveur
SERVER_PORT=8080
```

### Sécurité

1. **Changer les mots de passe par défaut**
2. **Utiliser des secrets forts pour JWT**
3. **Configurer HTTPS en production**
4. **Restreindre l'accès réseau**
5. **Configurer les sauvegardes**

### Monitoring

1. **Logs**
   - Les logs sont dans `deploy/logs/`
   - Configurer la rotation des logs

2. **Base de données**
   - Sauvegardes régulières
   - Monitoring des performances

3. **Application**
   - Health checks: http://localhost:8080/actuator/health
   - Métriques: http://localhost:8080/actuator/metrics

## Maintenance

### Sauvegardes

```bash
# Sauvegarde de la base de données
mysqldump -u eetsecom -p eetsecomdash > backup_$(date +%Y%m%d_%H%M%S).sql

# Sauvegarde des uploads
tar -czf uploads_backup_$(date +%Y%m%d_%H%M%S).tar.gz uploads/
```

### Mises à jour

1. **Arrêter l'application**
2. **Sauvegarder les données**
3. **Déployer la nouvelle version**
4. **Redémarrer l'application**
5. **Tester les fonctionnalités**

### Troubleshooting

**Problème: Application ne démarre pas**
- Vérifier les logs dans `deploy/logs/`
- Vérifier la configuration de la base de données
- Vérifier que le port 8080 est libre

**Problème: Erreur de base de données**
- Vérifier la connexion MySQL
- Vérifier les permissions utilisateur
- Vérifier les paramètres de connexion

**Problème: Erreur JWT**
- Vérifier la configuration JWT_SECRET
- Vérifier la date/heure du serveur

## Support

Pour toute question ou problème:
1. Consulter les logs de l'application
2. Vérifier la documentation
3. Contacter l'équipe de développement

## Checklist de déploiement

- [ ] Java 17+ installé
- [ ] MySQL configuré
- [ ] Base de données créée
- [ ] Variables d'environnement configurées
- [ ] Application compilée
- [ ] Tests effectués
- [ ] Sauvegardes configurées
- [ ] Monitoring configuré
- [ ] Documentation utilisateur fournie 