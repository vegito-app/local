- **Ticket 1.2 : Intégrer Authentification Google et Facebook**

  - Description : Ajouter support Google/Facebook, tests unitaires et e2e.
  - Priorité : Haute

# Ticket 1.2 : Intégrer Authentification Google et Facebook

## Objectif général

Ajouter la prise en charge des authentifications Google et Facebook dans l'application Flutter, avec les tests nécessaires.

## Sous-tickets détaillés

### 1.2.1 - Préparer la configuration Firebase

- Activer Google Sign-In dans la console Firebase.
- Activer Facebook Login dans la console Firebase.
- Enregistrer les clés SHA-1 et SHA-256 nécessaires pour Android.
- Obtenir les clés Facebook (App ID, App Secret) et les renseigner dans Firebase.

### 1.2.2 - Implémenter Google Sign-In (Flutter)

- Intégrer le package `google_sign_in` dans le projet Flutter.
- Ajouter la logique de connexion Google dans `auth_service.dart`.
- Ajouter un bouton Google sur l'écran `sign_in_page.dart`.
- Gérer les erreurs de connexion.

### 1.2.3 - Implémenter Facebook Login (Flutter)

- Intégrer le package `flutter_facebook_auth`.
- Ajouter la logique de connexion Facebook dans `auth_service.dart`.
- Ajouter un bouton Facebook sur `sign_in_page.dart`.
- Gérer les erreurs de connexion.

### 1.2.4 - Intégration Backend

- Vérifier que le token ID Firebase reste cohérent après les logins.
- Ajouter un test d'appel backend avec utilisateur authentifié via Google/Facebook.

### 1.2.5 - Tests unitaires et e2e

- Ajouter des tests unitaires Flutter pour les nouvelles méthodes dans `auth_service.dart`.
- Ajouter des tests robotframework dans les suites existantes :
  - Connexion Google.
  - Connexion Facebook.
  - Appel API backend après connexion.

### 1.2.6 - Ajustements UI/UX

- Vérifier la cohérence des messages d’erreur.
- Vérifier le bon affichage des boutons selon les plateformes (Android/iOS).

## Priorité

Haute
