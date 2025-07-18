# Guide de résolution - Modification des pièces jointes

## 🔍 **Problème identifié**

Lors de la modification d'une pièce jointe (sans changer le fichier, juste la description), l'application affiche une erreur "Aucun fichier fourni" même si la modification devrait être possible.

## 🎯 **Cause principale**

Le problème venait du contrôleur `PieceJointeController.java` qui vérifiait la présence d'un fichier ou d'un nom de fichier avant de traiter la requête. Pour les modifications de description uniquement, aucun fichier n'est fourni, ce qui causait l'erreur.

## 🛠️ **Solution appliquée**

### **1. Correction du contrôleur**

Le contrôleur a été modifié pour :
- Récupérer automatiquement le nom du fichier existant depuis la base de données
- Permettre les modifications de description sans nouveau fichier
- Ajouter des logs de débogage pour le suivi

### **2. Amélioration du frontend**

Le code JavaScript a été amélioré pour :
- Mieux gérer les cas où le nom du fichier n'est pas disponible
- Ajouter un flag `modification` pour indiquer le type d'opération
- Améliorer la gestion des erreurs

## 📋 **Étapes de test**

### **Test 1 : Modification de description**
1. Sélectionner un projet avec une pièce jointe
2. Cliquer sur "Modifier" pour la pièce jointe
3. Changer uniquement la description
4. Cliquer sur "Enregistrer"
5. Vérifier que la modification est appliquée

### **Test 2 : Modification avec nouveau fichier**
1. Sélectionner un projet avec une pièce jointe
2. Cliquer sur "Modifier" pour la pièce jointe
3. Sélectionner un nouveau fichier
4. Modifier la description
5. Cliquer sur "Enregistrer"
6. Vérifier que le nouveau fichier et la description sont appliqués

### **Test 3 : Test automatisé**
Exécuter le script de test :
```powershell
./test_modification_piece_jointe.ps1
```

## 🔧 **Code modifié**

### **PieceJointeController.java**
```java
// Avant
} else {
    return ResponseEntity.badRequest().body("Aucun fichier fourni");
}

// Après
} else {
    // Pour les modifications de description uniquement, récupérer le nom du fichier existant
    try {
        var projetOpt = projetService.getProjetById(projetId);
        if (projetOpt.isPresent()) {
            var projet = projetOpt.get();
            switch (type) {
                case "contrat":
                    filename = projet.getContratPieceJointe();
                    break;
                // ... autres cas
            }
            
            if (filename == null || filename.trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Aucune pièce jointe existante trouvée pour ce type");
            }
        } else {
            return ResponseEntity.badRequest().body("Projet non trouvé");
        }
    } catch (Exception e) {
        return ResponseEntity.status(500).body("Erreur lors de la récupération du projet: " + e.getMessage());
    }
}
```

### **dashboard.html**
```javascript
// Ajout d'un flag pour les modifications
if (nomFichier) {
    formData.append('nomFichier', nomFichier);
}
formData.append('modification', 'true');
```

## 📊 **Vérification après correction**

### **1. Vérifier les logs**
Cherchez dans les logs de l'application :
```
DEBUG - Ajout/Modification pièce jointe: projetId=X, type=contrat, filename=Y, description=Z
```

### **2. Tester l'API directement**
```bash
curl -X POST http://localhost:8080/api/pieces-jointes \
  -F "projetId=1" \
  -F "type=contrat" \
  -F "description=Nouvelle description" \
  -F "modification=true"
```

### **3. Vérifier la base de données**
```sql
-- Vérifier les descriptions des pièces jointes
SELECT id, numero_projet, contrat_piece_jointe, contrat_piece_jointe_description 
FROM projet 
WHERE contrat_piece_jointe IS NOT NULL;
```

## 🚨 **Problèmes connus résolus**

1. ✅ **"Aucun fichier fourni"** lors de la modification de description
2. ✅ **Erreur 400** lors de l'enregistrement sans nouveau fichier
3. ✅ **Perte de données** lors de la modification de description

## 🔄 **Maintenance**

### **Vérification régulière**
- Tester les modifications de pièces jointes après chaque déploiement
- Vérifier les logs pour détecter d'éventuelles erreurs
- Surveiller l'espace disque du dossier `uploads/`

### **Nettoyage**
- Supprimer régulièrement les fichiers orphelins dans `uploads/`
- Vérifier la cohérence entre la base de données et les fichiers physiques

## 📞 **Support**

En cas de problème persistant :
1. Vérifier les logs de l'application
2. Exécuter le script de diagnostic
3. Tester l'API directement
4. Vérifier les permissions du dossier `uploads/` 