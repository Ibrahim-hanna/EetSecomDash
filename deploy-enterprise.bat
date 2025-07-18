@echo off
echo ========================================
echo   DEPLOIEMENT EETSECOMDASH EN ENTREPRISE
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

echo [1/5] Nettoyage et compilation du projet...
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERREUR: Échec de la compilation
    pause
    exit /b 1
)

echo.
echo [2/5] Création du dossier de déploiement...
if not exist "deploy" mkdir deploy
if not exist "deploy/uploads" mkdir deploy\uploads
if not exist "deploy/logs" mkdir deploy\logs

echo.
echo [3/5] Copie des fichiers nécessaires...
copy "target\Springboot-0.0.1-SNAPSHOT.jar" "deploy\eetsecomdash.jar"
copy "application-prod.properties" "deploy\application.properties"
copy "start-enterprise.bat" "deploy\"
copy "stop-enterprise.bat" "deploy\"

echo.
echo [4/5] Création du script de démarrage...
echo @echo off > "deploy\start-enterprise.bat"
echo echo Demarrage de EetSecomDash... >> "deploy\start-enterprise.bat"
echo java -jar eetsecomdash.jar --spring.profiles.active=prod >> "deploy\start-enterprise.bat"
echo pause >> "deploy\start-enterprise.bat"

echo.
echo [5/5] Création du script d'arrêt...
echo @echo off > "deploy\stop-enterprise.bat"
echo echo Arret de EetSecomDash... >> "deploy\stop-enterprise.bat"
echo for /f "tokens=5" %%%%a in ('netstat -aon ^| findstr :8080') do taskkill /f /pid %%%%a >> "deploy\stop-enterprise.bat"
echo echo Application arretee. >> "deploy\stop-enterprise.bat"
echo pause >> "deploy\stop-enterprise.bat"

echo.
echo ========================================
echo   DEPLOIEMENT TERMINE AVEC SUCCES !
echo ========================================
echo.
echo Fichiers créés dans le dossier 'deploy':
echo - eetsecomdash.jar (application compilée)
echo - application.properties (configuration production)
echo - start-enterprise.bat (démarrage)
echo - stop-enterprise.bat (arrêt)
echo.
echo POUR DEMARRER L'APPLICATION:
echo 1. Aller dans le dossier 'deploy'
echo 2. Double-cliquer sur 'start-enterprise.bat'
echo 3. Ouvrir http://localhost:8080 dans le navigateur
echo.
echo POUR ARRETER L'APPLICATION:
echo Double-cliquer sur 'stop-enterprise.bat'
echo.
echo IMPORTANT: Configurez la base de données MySQL avant le premier démarrage
echo.
pause 