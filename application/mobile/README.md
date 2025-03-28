# Wallet app

A new Flutter project.

```mermaid
sequenceDiagram
    participant Utilisateur
    participant App (Mobile)
    participant Backend (Firestore)
    
    Utilisateur->>App (Mobile): Connexion
    App (Mobile)->>App (Mobile): Génère Private Key
    App (Mobile)->>App (Mobile): Génère Recovery Key
    App (Mobile)->>App (Mobile): XOR (Private Key, Recovery Key) → XorKey
    App (Mobile)->>Backend (Firestore): Envoie XorKey (jamais Recovery Key)
    App (Mobile)->>Utilisateur: Affiche Recovery Key et demande de la sauvegarder
    Utilisateur-->>App (Mobile): Stocke Recovery Key manuellement

    Note right of Backend (Firestore): Stocke seulement XorKey
    
    Utilisateur->>App (Mobile): Tentative de récupération
    App (Mobile)->>Backend (Firestore): Récupère XorKey
    Utilisateur->>App (Mobile): Fournit Recovery Key
    App (Mobile)->>App (Mobile): XOR (XorKey, Recovery Key) → Private Key retrouvée 🎉
```
# car2go

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
