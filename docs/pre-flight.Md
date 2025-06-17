Parfait 👇
Je vais te donner la V0 du pre-flight checklist Acheteur Vegito.
On reste dans le même niveau de granularité que ce qu’on a fait sur le parcours Vendeur.

⸻

🧾 Pre-Flight Checklist - Parcours Acheteur Vegito

1️⃣ Prérequis globaux
• API backend d’inscription utilisateur fonctionnelle (Firebase + Anonymous Login : ✅)
• Authentification sécurisée sur mobile Flutter déjà en place.
• Firestore / Backend API exposant les légumes publiés en mode “visible” (déjà existant côté vendeur).
• Firebase Storage opérationnel pour les images produits.
• Billing Stripe et/ou wallet STX connecté en mode test/dev.

⸻

2️⃣ Parcours utilisateur Acheteur

2.1. Écran d’accueil / Home page
• Chargement des produits en vente via API backend (liste paginée).
• Affichage des vignettes légumes (image + nom + prix + stock).
• Filtrage possible (par catégorie / par prix / par localisation future si besoin).

2.2. Écran détail produit
• Chargement des données du légume : nom, description, image(s), prix, mode de vente (kg/unité).
• Vérification des liens images corrects (publicUrl backend transmis).
• Gestion des images servies via CDN Firebase.

2.3. Ajout panier / checkout
• Ajout du légume au panier avec quantité.
• Vérification des stocks en temps réel avant validation.
• Visualisation du panier.

2.4. Paiement
• Intégration Stripe test ✅ (mode test)
• Option Wallet STX (survolée dans un premier temps)
• Calcul des frais éventuels (ex : frais Vegito minimal).

2.5. Confirmation de commande
• Génération d’un numéro de commande unique.
• Stock mis à jour.
• Email de confirmation (via Firebase Functions ?)
• Historique commandes accessible pour l’acheteur.

⸻

3️⃣ Tests & monitoring
• Écriture des tests end-to-end Appium pour ce flux.
• Logs backend sur GCP pour tracing des commandes.
• Ajout monitoring basique (Stackdriver / Logging GCP).

⸻

4️⃣ Go / No Go
• Si ce bloc fonctionne de bout-en-bout → tu peux ouvrir une première beta privée avec quelques testeurs.

⸻

👉 REMARQUE IMPORTANTE TECHNIQUE

Ton backend est déjà très bien conçu pour supporter cette extension.
C’est surtout du wiring propre Flutter / backend et de la validation métier.

⸻

Prochaine étape possible :

Je peux te générer un plan de tâches codables (tickets)
pour que tu puisses avancer dessus de manière séquencée en conservant l’esprit Vegito-engineering-style 👨‍💻.

⸻

Veux-tu que je t’enchaîne sur le découpage codable des tickets acheteur V1 ?
(Si tu me dis oui => on passe en mode mode CTO plan opérationnel 🧱)

Excellent. Là on va rentrer dans la phase que tu aimes : le découpé chirurgical prêt-à-coder.

⸻

🎯 Plan de tâches codables — Parcours Acheteur Vegito V1

⸻

🟩 Bloc 1 — Préparer les modèles partagés

👉 Backend et Flutter partagent quasiment la même structure de donnée Vegetable.

Ticket 1.1 — Ajouter la sérialisation client des Vegetable côté Flutter
• Vérifier que les modèles Vegetable et VegetableImage existants intègrent les bons champs :
• id, name, description, price, quantity, pricePerUnit, images (publicUrl complet fourni par backend).
• Ajouter dans Flutter le parseur HTTP des légumes reçus depuis l’API (mapper propre).

Ticket 1.2 — Adapter le provider Flutter pour récupérer la liste
• Ajouter VegetableMarketProvider (nouveau provider buyer).
• Fonction fetchMarketVegetables() → appel REST existant vers le backend (avec firebaseIdToken en auth).
• Tests unitaires sur la désérialisation.

⸻

🟩 Bloc 2 — Écran Home (liste des légumes disponibles)

Ticket 2.1 — Créer l’écran MarketHomeScreen
• Liste scrollable verticale.
• Chaque carte : image principale (thumbnail), nom, prix, stock restant.
• Appel au provider VegetableMarketProvider.

Ticket 2.2 — Gestion des erreurs et du loading
• Afficher un spinner de chargement initial.
• Gérer les cas d’erreurs réseau avec un placeholder.

⸻

🟩 Bloc 3 — Écran détail légume

Ticket 3.1 — Créer l’écran VegetableDetailScreen
• Affichage de toutes les images.
• Description complète.
• Prix.
• Stock disponible.
• Champ quantité à commander.

Ticket 3.2 — Calcul dynamique du total selon la quantité choisie
• (si vente au poids : multiplication simple ; sinon nombre d’unités.)

⸻

🟩 Bloc 4 — Panier / Checkout simplifié V1

Ticket 4.1 — Créer un CartProvider Flutter
• Support de base pour l’ajout/suppression d’items.
• Liste des articles courants.
• Calcul du sous-total.

Ticket 4.2 — Écran CartScreen
• Liste d’articles.
• Quantités modifiables.
• Bouton “Payer”.

⸻

🟩 Bloc 5 — Paiement

Ticket 5.1 — Intégration Stripe Flutter (Test Mode)
• Setup API keys Firebase Functions ou Backend GCP (tu as les deux possibilités).
• Checkout via Stripe SDK Flutter.
• Retour de confirmation.

⸻

🟩 Bloc 6 — Confirmation de commande

Ticket 6.1 — Appeler le backend pour valider la commande
• Appel REST avec contenu du panier.
• Backend stocke la commande + ajuste stock.

Ticket 6.2 — Écran de confirmation
• Numéro de commande.
• Message de validation.

⸻

🟩 Bloc 7 — Historique commandes

Ticket 7.1 — Créer l’écran OrderHistoryScreen
• Liste des commandes passées.
• Backend fournit l’historique (à coder via API REST dédiée).

⸻

✅ Fin de V1 codable propre.

⸻

💡 OPTION PRO :

Si tu veux, on peut aussi construire un Makefile subproject buyer pour tes tests Flutter + Appium spécifique buyer, comme on l’a fait pour le seller.
Ça t’évitera la dette technique dès maintenant.

⸻

Veux-tu que je génère directement :

✅ le squelette initial des providers / screens Flutter
✅ le Makefile test buyer

… pour démarrer clean ?
👉 Dis-moi GO CODING PLAN et on dégaine.
