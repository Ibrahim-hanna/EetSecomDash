# Modifications pour rendre tous les champs de projet optionnels

## Résumé des changements

Tous les champs pour ajouter ou modifier un projet sont maintenant **facultatifs**. Vous pouvez créer ou modifier un projet en ne remplissant que les champs que vous souhaitez.

## Modifications apportées

### 1. Entité Projet (`src/main/java/com/example/Springboot/model/Projet.java`)

- **Changement principal** : Le champ `numeroProjet` est maintenant optionnel
  ```java
  // Avant
  @Column(nullable = false, unique = true)
  private String numeroProjet;
  
  // Après
  @Column(nullable = true, unique = true)
  private String numeroProjet;
  ```

### 2. Service Projet (`src/main/java/com/example/Springboot/service/ProjetService.java`)

- **Méthode `toEntity()`** : Amélioration de la gestion des champs optionnels
  - Vérification que les valeurs ne sont pas null ou vides avant de les assigner
  - Nettoyage automatique des espaces avec `trim()`
  - Gestion des pièces jointes optionnelles

#### Exemple de gestion des champs optionnels :
```java
// Avant
projet.setNumeroProjet(dto.getNumeroProjet());

// Après
if (dto.getNumeroProjet() != null && !dto.getNumeroProjet().trim().isEmpty()) {
    projet.setNumeroProjet(dto.getNumeroProjet().trim());
}
```

## Fonctionnalités

### ✅ Création de projet
- Vous pouvez créer un projet avec **aucun champ rempli**
- Vous pouvez créer un projet avec **seulement quelques champs**
- Vous pouvez créer un projet avec **tous les champs remplis**

### ✅ Modification de projet
- Vous pouvez modifier un projet en **vidant certains champs**
- Vous pouvez modifier un projet en **ajoutant seulement quelques champs**
- Vous pouvez modifier un projet en **gardant certains champs et en modifiant d'autres**

### ✅ Champs concernés
Tous les champs sont maintenant optionnels :
- `numeroProjet` (était obligatoire avant)
- `client`
- `designation`
- `typeProjet`
- `responsableInterne`
- `responsableExterne`
- `dureeContractuelle`
- `dateDebut`
- `dateFinEffective`
- `avancement`
- `statutExecution`
- `montantContratTTC`
- `montantAvenant`
- `montantCumul`
- `montantEncaisse`
- `soldeRestant`
- `statutFacturation`
- `remarques`
- Toutes les pièces jointes

## Tests

### Scripts de test créés :
1. `test_projet_optional.ps1` - Test de création de projets avec champs optionnels
2. `test_update_projet_optional.ps1` - Test de modification de projets avec champs optionnels

### Comment exécuter les tests :
```powershell
# Démarrer l'application Spring Boot
./mvnw spring-boot:run

# Dans un autre terminal, exécuter les tests
./test_projet_optional.ps1
./test_update_projet_optional.ps1
```

## Exemples d'utilisation

### Créer un projet minimal :
```json
{
  "numeroProjet": "PROJ-001",
  "client": "Client Test"
}
```

### Créer un projet vide :
```json
{
  "numeroProjet": "",
  "client": "",
  "designation": ""
}
```

### Modifier un projet en vidant certains champs :
```json
{
  "id": 1,
  "numeroProjet": "",
  "client": "",
  "designation": "Nouvelle désignation"
}
```

## Compatibilité

- ✅ Compatible avec l'API existante
- ✅ Compatible avec la base de données existante
- ✅ Compatible avec le frontend existant
- ✅ Aucune modification nécessaire côté client

## Notes importantes

1. **Base de données** : Si vous avez des données existantes, elles continueront de fonctionner normalement
2. **Validation** : Aucune validation côté serveur n'empêche la création/modification avec des champs vides
3. **Frontend** : Le frontend peut continuer à envoyer des champs vides sans problème
4. **Performance** : Aucun impact sur les performances

## Migration

Aucune migration de base de données n'est nécessaire car nous avons seulement changé la contrainte `nullable` de `false` à `true` pour le champ `numeroProjet`. 