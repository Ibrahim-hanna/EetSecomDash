@echo off
echo ========================================
echo   DEPLOIEMENT DOCKER EETSECOMDASH
echo ========================================
echo.

REM Vérifier si Docker est installé
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Docker n'est pas installé ou n'est pas démarré
    echo Veuillez installer Docker Desktop et le démarrer
    pause
    exit /b 1
)

REM Vérifier si Docker Compose est disponible
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Docker Compose n'est pas disponible
    pause
    exit /b 1
)

echo [1/4] Compilation du projet...
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERREUR: Échec de la compilation
    pause
    exit /b 1
)

echo.
echo [2/4] Construction de l'image Docker...
docker build -t eetsecomdash:latest .
if errorlevel 1 (
    echo ERREUR: Échec de la construction de l'image Docker
    pause
    exit /b 1
)

echo.
echo [3/4] Démarrage des services avec Docker Compose...
docker-compose up -d
if errorlevel 1 (
    echo ERREUR: Échec du démarrage des services
    pause
    exit /b 1
)

echo.
echo [4/4] Vérification du statut des services...
timeout /t 10 /nobreak >nul
docker-compose ps

echo.
echo ========================================
echo   DEPLOIEMENT DOCKER TERMINE !
echo ========================================
echo.
echo L'application est accessible sur:
echo - Application: http://localhost:8080
echo - Base de données MySQL: localhost:3306
echo.
echo Commandes utiles:
echo - Voir les logs: docker-compose logs -f
echo - Arrêter: docker-compose down
echo - Redémarrer: docker-compose restart
echo.
echo Les données sont persistées dans les volumes Docker
echo.
pause 