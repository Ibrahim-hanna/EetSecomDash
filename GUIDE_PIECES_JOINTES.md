# Guide de résolution des problèmes de pièces jointes

## 🔍 **Problème identifié**

Certains projets permettent d'ajouter des pièces jointes et de les voir, tandis que d'autres affichent un message de succès lors de l'ajout mais ne montrent pas les pièces jointes.

## 🎯 **Cause principale**

Le problème vient de la méthode `toDTO()` dans `ProjetService.java` qui vérifie l'existence physique du fichier avant de l'inclure dans le DTO :

```java
if (projet.getContratPieceJointe() != null && pieceJointeExiste(projet.getContratPieceJointe())) {
    // Seulement si le fichier existe physiquement
}
```

Si le fichier n'existe pas dans le dossier `uploads/`, la pièce jointe n'est pas incluse dans le DTO, même si elle est enregistrée en base de données.

## 🛠️ **Solutions**

### **Solution 1 : Diagnostic automatique**

Exécutez le script de diagnostic pour identifier les projets problématiques :

```powershell
./diagnostic_pieces_jointes.ps1
```

### **Solution 2 : Correction automatique**

Exécutez le script de correction pour nettoyer les références manquantes :

```powershell
./corriger_pieces_jointes.ps1
```

### **Solution 3 : Vérification manuelle**

1. **Vérifier le dossier uploads :**
   ```powershell
   # Vérifier si le dossier existe
   Test-Path "uploads"
   
   # Lister les fichiers
   Get-ChildItem -Path "uploads" -File
   ```

2. **Vérifier la base de données :**
   - Ouvrez http://localhost:8080/h2-console
   - Connectez-vous avec les paramètres par défaut
   - Exécutez : `SELECT * FROM PROJET WHERE contrat_piece_jointe IS NOT NULL OR pv_reception_provisoire IS NOT NULL;`

3. **Vérifier les logs de l'application :**
   - Regardez les logs de l'application pour les messages `DEBUG - toDTO`
   - Cherchez les messages "non trouvé physiquement"

## 📋 **Étapes de résolution**

### **Étape 1 : Diagnostic**
```powershell
# Exécuter le diagnostic
./diagnostic_pieces_jointes.ps1
```

### **Étape 2 : Correction**
```powershell
# Exécuter la correction
./corriger_pieces_jointes.ps1
```

### **Étape 3 : Vérification**
1. Redémarrez l'application
2. Testez l'ajout de pièces jointes sur un projet
3. Vérifiez que les pièces jointes s'affichent correctement

## 🔧 **Causes possibles**

### **1. Fichiers manquants**
- Les fichiers ont été supprimés du dossier `uploads/` mais restent référencés en base
- Problème lors de l'upload (fichier non sauvegardé correctement)

### **2. Problème de permissions**
- L'application n'a pas les droits pour accéder au dossier `uploads/`
- Problème de droits d'écriture

### **3. Chemin incorrect**
- Le dossier `uploads/` n'existe pas
- Le chemin est mal configuré dans l'application

### **4. Problème de sauvegarde**
- Les fichiers ne sont pas correctement sauvegardés lors de l'upload
- Problème de nommage des fichiers

## 🚨 **Problèmes courants**

### **Problème 1 : "Fichier non trouvé physiquement"**
**Symptômes :** Message dans les logs indiquant qu'un fichier n'est pas trouvé
**Solution :**
1. Vérifiez que le fichier existe dans `uploads/`
2. Si le fichier n'existe pas, supprimez la référence en base
3. Rechargez le fichier

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

### **Test 1 : Ajout de pièce jointe**
1. Sélectionnez un projet
2. Ajoutez une pièce jointe
3. Vérifiez qu'elle s'affiche immédiatement

### **Test 2 : Affichage des pièces existantes**
1. Sélectionnez un projet avec des pièces jointes
2. Vérifiez que toutes les pièces jointes s'affichent
3. Testez le téléchargement des fichiers

### **Test 3 : Suppression de pièce jointe**
1. Supprimez une pièce jointe
2. Vérifiez qu'elle disparaît de l'interface
3. Vérifiez qu'elle est supprimée de la base

## 🔄 **Maintenance préventive**

### **Nettoyage régulier**
Exécutez périodiquement le script de diagnostic pour identifier les problèmes :

```powershell
# Diagnostic mensuel
./diagnostic_pieces_jointes.ps1
```

### **Sauvegarde des fichiers**
Assurez-vous de sauvegarder régulièrement le dossier `uploads/` :

```powershell
# Sauvegarde du dossier uploads
Copy-Item -Path "uploads" -Destination "backup/uploads_$(Get-Date -Format 'yyyyMMdd')" -Recurse
```

## 📞 **Support**

Si le problème persiste après avoir suivi ce guide :

1. **Vérifiez les logs de l'application** pour des erreurs spécifiques
2. **Testez avec un projet simple** pour isoler le problème
3. **Vérifiez la configuration** de l'application
4. **Contactez l'équipe de développement** avec les logs d'erreur

## 📝 **Notes importantes**

- Les pièces jointes sont stockées dans le dossier `uploads/` à la racine du projet
- Les noms de fichiers sont générés avec UUID pour éviter les conflits
- La vérification physique des fichiers est nécessaire pour la sécurité
- Les logs de débogage ont été ajoutés pour faciliter le diagnostic 