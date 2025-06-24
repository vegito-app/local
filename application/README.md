# Application

Ce dossier regroupe les différentes parties de l’application : backend, frontend web (React SSR), et application mobile (Flutter).

---

## 🔙 Backend

Le backend est écrit en Go. Il expose une API et sert le frontend React, avec un rendu server-side (SSR) basé sur `v8go`.

### Démarrer en local

```bash
make application-backend-run
```

### Construire une image Docker

```bash
make application-backend-image
```

### Lancer via docker-compose

```bash
make application-backend-docker-compose-up
```

### Targets disponibles

- `application-backend-install`
- `application-backend-run`
- `application-backend-image`
- `application-backend-image-push`
- `application-backend-docker-compose-up`
- `application-backend-docker-compose-logs`
- `application-backend-docker-compose-stop`
- `application-backend-docker-compose-rm`

Voir [application/backend/backend.mk](application/backend/backend.mk) pour plus de détails.

---

## 💻 Frontend (React + SSR)

Le frontend est une application React servie par le backend.

- React classique : [http://localhost:8080](http://localhost:8080)
- React pré-rendu côté serveur : [http://localhost:8080/ui](http://localhost:8080/ui)

### Build (SSR)

```bash
make application-frontend-build
```

### Dev server

```bash
make application-frontend-bundle
```

### Lancer le serveur React (mode dev uniquement)

```bash
make application-frontend-start
```

### Targets disponibles

- `application-frontend-build`
- `application-frontend-bundle`
- `application-frontend-start`
- `application-frontend-npm-ci`

Voir [application/frontend/frontend.mk](application/frontend/frontend.mk) pour plus de détails.

---

## 📱 Mobile (Flutter)

Une app mobile multiplateforme Flutter (Android/iOS).

### Installer les dépendances

```bash
make application-mobile-flutter-pub-get
```

### Compiler

```bash
make application-mobile-flutter-build
```

### Config Firebase

- iOS: `application/mobile/ios/GoogleService-Info.plist`
- Android: `application/mobile/android/app/google-services.json`

Voir [application/mobile](application/mobile) pour plus de détails.
