# Utiliser l'image OpenJDK 17 officielle
FROM openjdk:17-jdk-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier le fichier JAR de l'application
COPY target/Springboot-0.0.1-SNAPSHOT.jar app.jar

# Créer un utilisateur non-root pour exécuter l'application
RUN addgroup --system javauser && adduser --system --ingroup javauser javauser

# Changer la propriété du fichier JAR
RUN chown javauser:javauser app.jar

# Passer à l'utilisateur non-root
USER javauser

# Exposer le port 8080
EXPOSE 8080

# Commande pour démarrer l'application
ENTRYPOINT ["java", "-jar", "app.jar"] 