# 📦 Module Escrow + Réputation — Intégration Flutter avec Clarity

Ce module décrit comment intégrer un smart contract Clarity de type `Escrow + Reputation` dans une application Flutter avec wallet STX non-custodial et Firebase.

<!-- --- -->

<!-- ----- -->
<p>

## 🧱 Composants Flutter

  <img src="escrow.png" alt="Escrow" align="right" width="370" style="margin-right: 10px;">
  Ce module décrit comment intégrer un smart contract Clarity de type `Escrow + Reputation` dans une application Flutter avec wallet STX non-custodial et Firebase.<!-- Voici un paragraphe de texte qui s’affiche à côté de l’image. L’image est alignée à gauche et le texte l’entoure. -->
<!-- ![Diagramme du module Escrow](escrow.png) -->

### Widgets

- `EscrowPage` : saisie du montant, destinataire, bouton "Initier Escrow".
- `DeliveryStatusPage` : état de livraison, confirmation ou signalement de litige.
- `ReputationPage` : visualisation des réputations (filtrage, classement, historique).

### Exemple de synchro UI via Firestore

```json
"escrows": {
  "escrow-id-123": {
    "buyer": "wallet-address",
    "seller": "wallet-address",
    "status": "initiated|delivered|confirmed|disputed|resolved",
    "amount": 3000000,
    "reputation-snapshot": {
      "buyer": 5,
      "seller": 8
    }
  }
}
```

</p>

## 🧠 Intégration avec Stacks

Utilisation du SDK Flutter pour signer les appels Clarity.

Exemple :

```dart
final tx = ContractCall(
  contractAddress: 'SP...',
  contractName: 'escrow-contract',
  functionName: 'init-escrow',
  functionArgs: [
    ClarityValue.principalStandard('ST...')
  ]
);
final txId = await stacksWallet.signAndBroadcast(tx);
```

---

## 🔐 Backend & Sécurité

- Auth via Firebase.
- Backend Go pour logiques secondaires (monitoring, timeouts, alertes).
- Vault HA sur GKE pour les secrets, adresses arbitres, listes noires.

---

## 🔄 Worker de résolution

- Déploiement Cloud Run ou GKE.
- Tâches :
  - Détection escrows bloqués > 48h.
  - Lancement `resolve-dispute` si réputation ou délai critique.
  - Notification utilisateur.

---

## ✅ Recommandations

| Élément          | Recommandation                                           |
| ---------------- | -------------------------------------------------------- |
| Auth utilisateur | Firebase + lien avec wallet STX                          |
| Signature        | Ne jamais exposer la seed                                |
| Réputation       | Stocker + appeler fonction `get-reputation()` en Clarity |
| Sécurité         | Vault + contrôle backend                                 |
| UX               | Pas de vocabulaire "blockchain" en frontal               |
| Monitoring       | Logs / PubSub pour litiges ou fraudes                    |

---

## 📌 Prochaines étapes

- [ ] Développer le widget `EscrowPage`.
- [ ] Écrire les appels Dart vers le contrat Clarity.
- [ ] Implémenter les règles de réputation dans la Firestore.
- [ ] Ajouter la logique d’escalade backend.

---
