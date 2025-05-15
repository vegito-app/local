## Procédure d'accès pour un nouveau développeur autorisé

### Prérequis

- Avoir été ajouté via Terraform dans le fichier `users.tf` (accès SSH autorisé sur la machine `n2`).
- Posséder une clé SSH publique.
- Avoir installé le SDK GCloud localement (`gcloud`).
- Un compte de service avec les autorisations nécessaires pour `compute.instances.*` (start, stop, suspend, resume) est utilisé pour automatiser certaines tâches.

### Accès SSH automatique

Une fois autorisé :

1. Configurez votre compte avec :

   ```bash
   gcloud auth login
   gcloud config set project [YOUR_PROJECT_ID]
   gcloud compute ssh dev-[VOTRE_NOM] --zone=europe-west1-b
   ```

2. Cette commande démarre la VM si elle est en mode hibernation (la reprise est automatique) ou affiche une erreur si elle est arrêtée.

### Hibernation automatique

La VM passe en hibernation si aucun utilisateur n'est connecté via SSH, grâce au script `dev-shutdown-script.sh.sh`. Celui-ci est exécuté régulièrement via un planificateur (Cloud Scheduler ou cron externe).

```bash
who | wc -l
```

Si ce nombre est 0, la machine entre en hibernation :

```bash
gcloud compute instances suspend [VM_NAME]
```

### Coût de l'hibernation

Une VM en hibernation ne facture **pas le vCPU ni la RAM**, seulement :

- Le **stockage** du disque persistant.
- Le **stockage de l’état hiberné** (équivalent à la RAM provisionnée).

Cela permet de réduire fortement les coûts tout en conservant l’état exact de la machine au réveil.

### Redémarrage manuel

```bash
make start
```

### Mise en veille manuelle

```bash
make suspend
```

### Vérifier l’état de la machine

```bash
make status
```
