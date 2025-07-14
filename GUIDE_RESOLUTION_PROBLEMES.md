# Guide de résolution des problèmes - Affichage des projets

## 🔍 Problème identifié
Les informations des projets ne s'affichent pas dans le dashboard malgré leur présence dans la base de données.

## 📋 Étapes de diagnostic

### 1. Vérifier que l'application est démarrée
```powershell
# Démarrer l'application
./mvnw spring-boot:run
```

### 2. Vérifier les logs de l'application
Regardez la console où vous avez lancé l'application et cherchez :
- `=== DEBUG DASHBOARD ===`
- `=== DEBUG PROJET SERVICE ===`
- Messages d'erreur contenant "projet", "ProjetService", ou "dashboard"

### 3. Tester l'API directement
```powershell
# Exécuter le script de diagnostic
./diagnostic_complet.ps1
```

### 4. Vérifier la base de données
1. Ouvrez votre navigateur
2. Allez à : http://localhost:8080/h2-console
3. Paramètres de connexion :
   - **JDBC URL :** `jdbc:h2:file:./data/testdb`
   - **Username :** `sa`
   - **Password :** (laissez vide)
4. Exécutez la requête : `SELECT * FROM PROJET;`

### 5. Tester l'authentification
```powershell
# Exécuter le script de test d'authentification
./test_auth_dashboard.ps1
```

## 🛠️ Solutions possibles

### Solution 1 : Problème d'authentification
**Symptômes :** Dashboard accessible mais projets vides
**Solution :**
1. Vérifiez que vous êtes connecté avec un rôle approprié (ADMIN, SUPERVISEUR, EMPLOYE)
2. Créez un compte de test si nécessaire

### Solution 2 : Base de données vide
**Symptômes :** Aucun projet dans la base de données
**Solution :**
1. Créez des projets de test via l'API :
```powershell
./test_projet_optional.ps1
```

### Solution 3 : Problème de conversion DTO
**Symptômes :** Projets en base mais pas affichés
**Solution :**
1. Vérifiez les logs de débogage ajoutés
2. Regardez les messages `=== DEBUG PROJET SERVICE ===`

### Solution 4 : Problème JavaScript
**Symptômes :** Projets récupérés par l'API mais pas affichés
**Solution :**
1. Ouvrez la console du navigateur (F12)
2. Allez sur le dashboard
3. Regardez les erreurs JavaScript

## 🔧 Modifications apportées

### 1. Logs de débogage ajoutés
- **WebAuthController :** Logs pour le dashboard
- **ProjetService :** Logs pour la récupération des projets

### 2. Validation des champs optionnels
- **Dashboard HTML :** Suppression des validations obligatoires
- **Service :** Gestion des champs null/vides

### 3. Scripts de test créés
- `diagnostic_complet.ps1` - Diagnostic complet
- `test_auth_dashboard.ps1` - Test d'authentification
- `test_projet_optional.ps1` - Test des champs optionnels

## 📊 Vérification étape par étape

### Étape 1 : Vérifier l'application
```powershell
# Test de base
Invoke-WebRequest -Uri "http://localhost:8080" -Method GET
```

### Étape 2 : Vérifier l'API
```powershell
# Test de l'API projets
Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
```

### Étape 3 : Vérifier le dashboard
1. Ouvrez http://localhost:8080
2. Connectez-vous
3. Vérifiez le dashboard

### Étape 4 : Vérifier la console H2
1. Ouvrez http://localhost:8080/h2-console
2. Connectez-vous avec les paramètres ci-dessus
3. Exécutez : `SELECT * FROM PROJET;`

## 🚨 Problèmes courants

### Problème 1 : "Application non accessible"
**Cause :** Application non démarrée
**Solution :** `./mvnw spring-boot:run`

### Problème 2 : "Erreur API projets"
**Cause :** Problème d'authentification ou de base de données
**Solution :** Vérifiez les logs et la base de données

### Problème 3 : "Dashboard vide"
**Cause :** Problème JavaScript ou données manquantes
**Solution :** Vérifiez la console du navigateur

### Problème 4 : "Base de données vide"
**Cause :** Aucun projet créé
**Solution :** Créez des projets de test

## 📞 Support

Si le problème persiste :
1. Exécutez tous les scripts de diagnostic
2. Notez les messages d'erreur
3. Vérifiez les logs de l'application
4. Testez avec un compte ADMIN

## ✅ Checklist de vérification

- [ ] Application démarrée (port 8080)
- [ ] Base de données accessible (H2 console)
- [ ] Projets présents en base de données
- [ ] API projets répond correctement
- [ ] Utilisateur connecté avec un rôle approprié
- [ ] Dashboard accessible après connexion
- [ ] Projets visibles dans le sélecteur
- [ ] Aucune erreur dans la console du navigateur 