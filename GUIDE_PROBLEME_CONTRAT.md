# Guide de résolution - Problème spécifique du contrat

## 🔍 **Problème identifié**

Le problème spécifique concerne la modification des pièces jointes de type **"contrat"**. Lors de la modification d'une remarque/description sur un contrat existant, l'application affiche une erreur.

## 🎯 **Cause principale**

Le problème vient de la méthode `pieceJointeExiste()` dans `ProjetService.java` qui vérifie l'existence physique du fichier avant de l'inclure dans le DTO :

```java
if (pieceJointeExiste(projet.getContratPieceJointe())) {
    // Seulement si le fichier existe physiquement
    dto.getPiecesJointes().contrat = pj;
} else {
    // Le fichier n'existe pas physiquement, donc pas inclus dans le DTO
    System.out.println("DEBUG - Contrat non trouvé physiquement: " + projet.getContratPieceJointe());
}
```

**Résultat :** Si le fichier du contrat n'existe pas dans le dossier `uploads/`, la pièce jointe n'est pas incluse dans le DTO, même si elle est enregistrée en base de données.

## 🛠️ **Solutions**

### **Solution 1 : Diagnostic automatique**
Exécutez le script de diagnostic pour identifier les contrats problématiques :

```powershell
./diagnostic_contrat.ps1
```

### **Solution 2 : Correction automatique**
Exécutez le script de correction pour résoudre le problème :

```powershell
./corriger_contrat.ps1
```

### **Solution 3 : Vérification manuelle**

#### **Étape 1 : Vérifier le dossier uploads**
```powershell
# Vérifier si le dossier existe
Test-Path "uploads"

# Lister les fichiers
Get-ChildItem -Path "uploads" -File
```

#### **Étape 2 : Vérifier la base de données**
```sql
-- Vérifier les contrats en base
SELECT id, numero_projet, contrat_piece_jointe, contrat_piece_jointe_description 
FROM projet 
WHERE contrat_piece_jointe IS NOT NULL;
```

#### **Étape 3 : Vérifier les logs**
Cherchez dans les logs de l'application :
```
DEBUG - Contrat non trouvé physiquement: [nom_du_fichier]
```

## 📋 **Étapes de résolution**

### **Étape 1 : Diagnostic**
```powershell
# Exécuter le diagnostic
./diagnostic_contrat.ps1
```

**Résultats attendus :**
- ✓ Application accessible
- ✓ Dossier uploads existe
- Liste des projets avec contrats problématiques
- Test de modification d'un contrat

### **Étape 2 : Correction**
```powershell
# Exécuter la correction
./corriger_contrat.ps1
```

**Actions effectuées :**
- Création du dossier `uploads/` s'il n'existe pas
- Création de fichiers temporaires pour les contrats manquants
- Vérification après correction

### **Étape 3 : Test de modification**
1. Ouvrir l'application
2. Sélectionner un projet avec un contrat
3. Cliquer sur "✏️ Modifier" sur le contrat
4. Ajouter/modifier la description
5. Cliquer sur "Enregistrer"
6. Vérifier que la modification est appliquée

## 🔧 **Causes possibles du problème**

### **1. Fichiers manquants**
- Les fichiers de contrats ont été supprimés du dossier `uploads/`
- Problème lors de l'upload initial (fichier non sauvegardé correctement)

### **2. Dossier uploads manquant**
- Le dossier `uploads/` n'existe pas
- Problème de permissions sur le dossier

### **3. Problème de sauvegarde**
- Les fichiers ne sont pas correctement sauvegardés lors de l'upload
- Problème de nommage des fichiers

### **4. Problème de chemin**
- Le chemin vers le dossier `uploads/` est incorrect
- Problème de configuration de l'application

## 🚨 **Problèmes courants**

### **Problème 1 : "Contrat non trouvé physiquement"**
**Symptômes :** Message dans les logs indiquant qu'un fichier de contrat n'est pas trouvé
**Solution :**
1. Vérifiez que le fichier existe dans `uploads/`
2. Si le fichier n'existe pas, utilisez le script de correction
3. Ou rechargez le fichier original

### **Problème 2 : "Dossier uploads manquant"**
**Symptômes :** Erreur lors de l'upload de fichiers
**Solution :**
```powershell
# Créer le dossier uploads
New-Item -ItemType Directory -Path "uploads" -Force
```

### **Problème 3 : "Permissions insuffisantes"**
**Symptômes :** Erreur lors de l'écriture de fichiers
**Solution :**
1. Vérifiez les permissions du dossier `uploads/`
2. Donnez les droits d'écriture à l'application

## 📊 **Vérification après correction**

### **Test 1 : Modification de description**
1. Sélectionner un projet avec contrat
2. Modifier la description du contrat
3. Vérifier que la modification est appliquée

### **Test 2 : Modification avec nouveau fichier**
1. Sélectionner un projet avec contrat
2. Modifier le contrat avec un nouveau fichier
3. Vérifier que le nouveau fichier et la description sont appliqués

### **Test 3 : Test de tous les contrats**
Tester la modification pour tous les projets ayant des contrats :
```powershell
# Récupérer tous les projets avec contrats
$projets = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
$projetsAvecContrat = $projets | Where-Object { 
    $_.piecesJointes -and $_.piecesJointes.contrat -and $_.piecesJointes.contrat.nomFichier 
}
Write-Host "Projets avec contrats: $($projetsAvecContrat.Count)"
```

## 🔍 **Diagnostic avancé**

### **Vérifier les logs de l'application**
```bash
# Chercher les messages DEBUG dans les logs
grep "DEBUG.*contrat" logs/application.log
grep "Contrat non trouvé physiquement" logs/application.log
```

### **Tester l'API directement**
```bash
# Test de modification d'un contrat
curl -X POST http://localhost:8080/api/pieces-jointes \
  -F "projetId=1" \
  -F "type=contrat" \
  -F "nomFichier=contrat_existant.pdf" \
  -F "description=Test modification contrat"
```

### **Vérifier la base de données**
```sql
-- Vérifier les contrats et leurs descriptions
SELECT 
    id, 
    numero_projet, 
    contrat_piece_jointe, 
    contrat_piece_jointe_description,
    CASE 
        WHEN contrat_piece_jointe IS NOT NULL THEN 'Avec contrat'
        ELSE 'Sans contrat'
    END as statut
FROM projet 
ORDER BY id;
```

## ✅ **Résultat attendu**

Après application des corrections :
- ✅ Modification de description des contrats fonctionne
- ✅ Modification avec nouveau fichier fonctionne
- ✅ Tous les contrats existants sont visibles
- ✅ Interface utilisateur cohérente
- ✅ Gestion des erreurs améliorée

## 📝 **Notes importantes**

1. **Fichiers temporaires :** Le script de correction crée des fichiers temporaires pour résoudre le problème immédiat. Pour une solution permanente, vous devrez recharger les vrais fichiers.

2. **Sauvegarde :** Avant d'exécuter les scripts de correction, faites une sauvegarde de votre base de données.

3. **Permissions :** Assurez-vous que l'application a les droits d'écriture sur le dossier `uploads/`.

4. **Redémarrage :** Après les corrections, redémarrez l'application pour s'assurer que tous les changements sont pris en compte. 