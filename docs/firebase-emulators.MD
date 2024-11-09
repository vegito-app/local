## Firebase Emulators

L’outil Firebase Emulators peut être utilisé aussi bien en local que dans des environnements de type cloud, sous certaines conditions, bien que son usage soit généralement destiné à un poste de développement local.

Utilisation des Firebase Emulators en local

L’usage typique des Firebase Emulators est pour le développement local, car ils permettent de tester les fonctionnalités Firebase (Auth, Firestore, Functions, etc.) sans coûts ni impacts sur la production. Les émulateurs sont optimisés pour être utilisés sur des machines locales pour des raisons de performance, de confidentialité, et de facilité de configuration.

Utilisation des Firebase Emulators en environnement Cloud (staging/dev)

Il est possible, bien qu’inhabituel, d’utiliser les Firebase Emulators dans un environnement de staging ou dev dans le cloud, comme sur un service Cloud Run, Kubernetes, ou une VM GCP, mais cela comporte des limitations :
	1.	Portabilité et latence :
	•	Les émulateurs sont conçus pour un usage local, donc leur exécution dans un environnement cloud peut introduire des latences supplémentaires.
	•	La redirection des ports et la communication peuvent être complexes à configurer, surtout avec des services comme Cloud Run où le trafic entrant est limité par défaut.
	2.	Configuration réseau et sécurité :
	•	Pour que les Firebase Emulators fonctionnent dans un environnement de staging ou dev sur le cloud, il faut configurer un accès réseau adéquat. Par exemple, dans un environnement restreint (Cloud Run ou VM privée), il est nécessaire de configurer l’accès aux ports que chaque émulateur utilise.
	•	Il est aussi important de gérer soigneusement les accès et de restreindre l’environnement pour éviter une exposition des émulateurs Firebase à Internet.
	3.	Cas d’usage sur un environnement cloud :
	•	Cela peut être utile pour automatiser des tests d’intégration continue en environnement isolé, comme dans un environnement CI/CD basé sur Cloud Run ou Kubernetes, où les émulateurs seraient lancés temporairement pendant les tests.
	•	Pour les environnements partagés par une équipe de développeurs, cela peut également permettre des tests de bout en bout sans toucher aux données de production.
	4.	Déploiement et orchestration :
	•	Sur un environnement cloud, l’exécution des émulateurs peut nécessiter une orchestration via un script (par exemple, un script Docker ou dans un environnement orchestré comme Kubernetes), car les Firebase Emulators ne s’intègrent pas automatiquement aux plateformes de conteneurs.

Solution alternative : utiliser des environnements de test Firebase

Google propose des environnements de test Firebase directement sur le projet Firebase, comme les environnements de test Firestore. Cela permet de créer des collections ou d’exécuter des tests sans avoir à utiliser les émulateurs. Cependant, cela n’est pas gratuit et nécessite un environnement connecté à Firebase en ligne.

Conclusion

Les Firebase Emulators sont conçus pour un usage local, mais peuvent fonctionner en environnements staging ou dev sur le cloud avec une configuration spécifique. Cependant, il est recommandé de les limiter au développement local ou aux tests CI/CD orchestrés de courte durée.