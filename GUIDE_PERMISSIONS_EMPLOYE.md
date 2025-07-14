# Guide des Permissions Employé

## 🎯 Objectif
Masquer les boutons d'action (Ajouter, Modifier, Supprimer) pour les utilisateurs avec le rôle `EMPLOYE` dans l'application.

## ✅ Modifications Apportées

### 1. Template Thymeleaf (dashboard.html)

#### Boutons d'action des projets
- **Avant** : Les boutons "Ajouter", "Modifier", "Supprimer" étaient toujours visibles
- **Après** : Masqués pour les employés avec `th:if="${userRole != 'EMPLOYE'}"`

#### Boutons d'action des pièces jointes
- **Avant** : Les boutons "Modifier" et "Supprimer" des pièces jointes étaient toujours visibles
- **Après** : Masqués pour les employés avec `th:if="${userRole != 'EMPLOYE'}"`

### 2. JavaScript (dashboard.html)

#### Contrôle de visibilité des boutons
```javascript
// Actions CRUD
const actions = document.getElementById('actionsProjet');
const btnAddPieceJointe = document.getElementById('btnAddPieceJointe');
if (userRole !== 'ADMIN' && userRole !== 'SUPERVISEUR') {
    actions.style.display = 'none';
    if (btnAddPieceJointe) btnAddPieceJointe.style.display = 'none';
} else {
    actions.style.display = 'flex';
    if (btnAddPieceJointe) btnAddPieceJointe.style.display = 'inline-block';
}
```

#### Vérification des permissions dans les fonctions
- **modifierPieceJointe()** : Ajout de vérification du rôle
- **supprimerPieceJointe()** : Ajout de vérification du rôle
- **Formulaire projet** : Ajout de vérification du rôle
- **Formulaire pièce jointe** : Ajout de vérification du rôle

#### Sections dynamiques
- Les boutons d'action dans les sections générées par JavaScript sont masqués avec :
```javascript
${userRole === 'EMPLOYE' ? 'style="display: none;"' : ''}
```

### 3. Messages d'erreur
Ajout de messages d'alerte pour informer l'utilisateur qu'il n'a pas les permissions :
```javascript
if (userRole === 'EMPLOYE') {
    showAlert('Vous n\'avez pas les permissions pour effectuer cette action.', 'warning');
    return;
}
```

## 🔒 Sécurité

### Niveaux de protection
1. **Frontend** : Masquage des boutons d'action
2. **JavaScript** : Vérification des permissions avant exécution
3. **Backend** : Contrôle d'accès via Spring Security

### Rôles autorisés pour les actions
- **ADMIN** : Toutes les actions autorisées
- **SUPERVISEUR** : Toutes les actions autorisées
- **EMPLOYE** : Lecture seule, aucune action de modification

## 🧪 Tests

### Script de test
Utilisez le script `test_employe_permissions.ps1` pour vérifier :
1. Création d'un utilisateur employé
2. Connexion en tant qu'employé
3. Test d'accès au dashboard
4. Test des restrictions API

### Vérification manuelle
1. Connectez-vous avec un compte employé
2. Vérifiez que les boutons "Ajouter", "Modifier", "Supprimer" sont masqués
3. Vérifiez que les boutons d'action des pièces jointes sont masqués
4. Testez les tentatives d'action via la console JavaScript

## 📋 Checklist de vérification

- [ ] Les boutons d'action des projets sont masqués pour les employés
- [ ] Les boutons d'action des pièces jointes sont masqués pour les employés
- [ ] Les messages d'erreur s'affichent si un employé tente une action
- [ ] Les employés peuvent toujours consulter les projets
- [ ] Les employés peuvent toujours télécharger les pièces jointes
- [ ] Les administrateurs et superviseurs conservent tous leurs droits

## 🚀 Déploiement

1. Redémarrez l'application Spring Boot
2. Testez avec différents rôles utilisateur
3. Vérifiez que les modifications fonctionnent en production

## 🔧 Dépannage

### Problèmes courants
1. **Boutons toujours visibles** : Vérifiez que `userRole` est correctement passé au template
2. **Erreurs JavaScript** : Vérifiez la console du navigateur
3. **Permissions backend** : Vérifiez la configuration Spring Security

### Logs utiles
- Vérifiez les logs de l'application pour les erreurs d'authentification
- Surveillez les tentatives d'accès non autorisées 