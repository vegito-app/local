# Clé API Firebase (FCM, Auth, Firestore, etc.)

- Clé restreinte à 25 APIs utilisées par Firebase
- Aucune restriction IP ou SHA1 → compatible avec devcontainer / émulateurs
- Clé utilisée dans `google-services.json` Android
- Ne pas partager cette clé en public même si restreinte (bonne pratique)

# Clé API Google Maps

- Clé utilisée dans `firebase_config_web` (injection côté React frontend)
- À restreindre par domaine (`localhost`, `*.mydomain.dev`, etc.)
