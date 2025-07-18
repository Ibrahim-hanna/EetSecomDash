-- Script d'initialisation de la base de données EetSecomDash
-- Ce script sera exécuté automatiquement lors du premier démarrage du conteneur MySQL

USE eetsecomdash;

-- Création des tables (sera géré par Hibernate)
-- Les tables seront créées automatiquement par Spring Boot avec ddl-auto=update

-- Insertion d'utilisateurs de base (optionnel)
-- Ces insertions peuvent être faites via l'application ou via des scripts de migration

-- Exemple d'insertion d'un administrateur par défaut
-- INSERT INTO users (username, email, password, role, enabled) 
-- VALUES ('admin', 'admin@eetsecom.com', '$2a$10$encoded_password', 'ADMIN', true);

-- Note: Les mots de passe doivent être encodés avec BCrypt
-- Utilisez l'application pour créer les utilisateurs initiaux 