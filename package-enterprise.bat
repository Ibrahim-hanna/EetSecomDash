@echo off
echo ========================================
echo   CREATION DU PACKAGE ENTREPRISE
echo ========================================
echo.

REM Vérifier si Java est installé
java -version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Java n'est pas installé ou n'est pas dans le PATH
    echo Veuillez installer Java 17 ou supérieur
    pause
    exit /b 1
)

REM Vérifier si Maven est installé
mvn -version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Maven n'est pas installé ou n'est pas dans le PATH
    echo Veuillez installer Maven 3.6+
    pause
    exit /b 1
)

echo [1/6] Nettoyage et compilation du projet...
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERREUR: Échec de la compilation
    pause
    exit /b 1
)

echo.
echo [2/6] Création du dossier package-entreprise...
if exist "package-entreprise" rmdir /s /q "package-entreprise"
mkdir package-entreprise
mkdir package-entreprise\deploy
mkdir package-entreprise\deploy\uploads
mkdir package-entreprise\deploy\logs
mkdir package-entreprise\docs
mkdir package-entreprise\scripts

echo.
echo [3/6] Copie des fichiers de déploiement...
copy "target\Springboot-0.0.1-SNAPSHOT.jar" "package-entreprise\deploy\eetsecomdash.jar"
copy "application-prod.properties" "package-entreprise\deploy\application.properties"
copy "Dockerfile" "package-entreprise\"
copy "docker-compose.yml" "package-entreprise\"
copy "init.sql" "package-entreprise\"

echo.
echo [4/6] Copie de la documentation...
copy "GUIDE_DEPLOIEMENT_ENTREPRISE.md" "package-entreprise\docs\"
copy "README.md" "package-entreprise\docs\"
copy "LICENSE" "package-entreprise\docs\"

echo.
echo [5/6] Création des scripts de déploiement...
echo @echo off > "package-entreprise\scripts\deploy-jar.bat"
echo echo Demarrage du deploiement JAR... >> "package-entreprise\scripts\deploy-jar.bat"
echo cd /d "%%~dp0..\deploy" >> "package-entreprise\scripts\deploy-jar.bat"
echo java -jar eetsecomdash.jar --spring.profiles.active=prod >> "package-entreprise\scripts\deploy-jar.bat"
echo pause >> "package-entreprise\scripts\deploy-jar.bat"

echo @echo off > "package-entreprise\scripts\deploy-docker.bat"
echo echo Demarrage du deploiement Docker... >> "package-entreprise\scripts\deploy-docker.bat"
echo cd /d "%%~dp0.." >> "package-entreprise\scripts\deploy-docker.bat"
echo docker-compose up -d >> "package-entreprise\scripts\deploy-docker.bat"
echo echo Application accessible sur http://localhost:8080 >> "package-entreprise\scripts\deploy-docker.bat"
echo pause >> "package-entreprise\scripts\deploy-docker.bat"

echo @echo off > "package-entreprise\scripts\stop-app.bat"
echo echo Arret de l'application... >> "package-entreprise\scripts\stop-app.bat"
echo for /f "tokens=5" %%%%a in ('netstat -aon ^| findstr :8080') do taskkill /f /pid %%%%a >> "package-entreprise\scripts\stop-app.bat"
echo echo Application arretee. >> "package-entreprise\scripts\stop-app.bat"
echo pause >> "package-entreprise\scripts\stop-app.bat"

echo @echo off > "package-entreprise\scripts\backup-db.bat"
echo echo Sauvegarde de la base de donnees... >> "package-entreprise\scripts\backup-db.bat"
echo mysqldump -u eetsecom -p eetsecomdash ^> backup_%%date:~-4,4%%%%date:~-10,2%%%%date:~-7,2%%_%%time:~0,2%%%%time:~3,2%%%%time:~6,2%%.sql >> "package-entreprise\scripts\backup-db.bat"
echo echo Sauvegarde terminee. >> "package-entreprise\scripts\backup-db.bat"
echo pause >> "package-entreprise\scripts\backup-db.bat"

echo.
echo [6/6] Création du fichier README pour l'entreprise...
echo # EetSecomDash - Package Entreprise > "package-entreprise\README_ENTREPRISE.md"
echo. >> "package-entreprise\README_ENTREPRISE.md"
echo ## Contenu du package >> "package-entreprise\README_ENTREPRISE.md"
echo. >> "package-entreprise\README_ENTREPRISE.md"
echo - **deploy/** : Fichiers de déploiement >> "package-entreprise\README_ENTREPRISE.md"
echo   - eetsecomdash.jar : Application compilée >> "package-entreprise\README_ENTREPRISE.md"
echo   - application.properties : Configuration production >> "package-entreprise\README_ENTREPRISE.md"
echo   - uploads/ : Dossier pour les fichiers uploadés >> "package-entreprise\README_ENTREPRISE.md"
echo   - logs/ : Dossier pour les logs >> "package-entreprise\README_ENTREPRISE.md"
echo. >> "package-entreprise\README_ENTREPRISE.md"
echo - **docs/** : Documentation complète >> "package-entreprise\README_ENTREPRISE.md"
echo - **scripts/** : Scripts de déploiement et maintenance >> "package-entreprise\README_ENTREPRISE.md"
echo - **Dockerfile** : Configuration Docker >> "package-entreprise\README_ENTREPRISE.md"
echo - **docker-compose.yml** : Orchestration Docker >> "package-entreprise\README_ENTREPRISE.md"
echo. >> "package-entreprise\README_ENTREPRISE.md"
echo ## Démarrage rapide >> "package-entreprise\README_ENTREPRISE.md"
echo. >> "package-entreprise\README_ENTREPRISE.md"
echo ### Option 1: Déploiement JAR >> "package-entreprise\README_ENTREPRISE.md"
echo 1. Installer Java 17+ et MySQL 8.0+ >> "package-entreprise\README_ENTREPRISE.md"
echo 2. Configurer la base de données MySQL >> "package-entreprise\README_ENTREPRISE.md"
echo 3. Modifier deploy/application.properties >> "package-entreprise\README_ENTREPRISE.md"
echo 4. Exécuter scripts/deploy-jar.bat >> "package-entreprise\README_ENTREPRISE.md"
echo. >> "package-entreprise\README_ENTREPRISE.md"
echo ### Option 2: Déploiement Docker >> "package-entreprise\README_ENTREPRISE.md"
echo 1. Installer Docker Desktop >> "package-entreprise\README_ENTREPRISE.md"
echo 2. Exécuter scripts/deploy-docker.bat >> "package-entreprise\README_ENTREPRISE.md"
echo. >> "package-entreprise\README_ENTREPRISE.md"
echo ## Support >> "package-entreprise\README_ENTREPRISE.md"
echo Consulter docs/GUIDE_DEPLOIEMENT_ENTREPRISE.md pour plus de détails. >> "package-entreprise\README_ENTREPRISE.md"

echo.
echo ========================================
echo   PACKAGE ENTREPRISE CREE AVEC SUCCES !
echo ========================================
echo.
echo Le package est disponible dans le dossier 'package-entreprise'
echo.
echo Contenu créé:
echo - Application compilée (JAR)
echo - Configuration production
echo - Scripts de déploiement
echo - Documentation complète
echo - Configuration Docker
echo.
echo POUR LIVRER A L'ENTREPRISE:
echo 1. Compresser le dossier 'package-entreprise'
echo 2. Envoyer le fichier ZIP
echo 3. Fournir les instructions de déploiement
echo.
pause 