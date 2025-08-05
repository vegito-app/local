*** Settings ***
Library           AppiumLibrary
Library           Collections

Resource         ../resources/keywords.robot
Resource         ../resources/vegetable.robot

Test Setup        Reset State And Return Home
# Test Teardown     Capture Screenshot On Failure

*** Variables ***
${REMOTE_URL}     http://android-studio:4723
${PLATFORM_NAME}  Android
${APP_PACKAGE}    dev.vegito.app.android
${APP_ACTIVITY}   .MainActivity

*** Keywords ***
Appuyer Sur Le Bouton Acheter Des Légumes
    Wait Until Page Contains Element    accessibility_id=🥬 Commander des légumes
    Click Element                       accessibility_id=🥬 Commander des légumes        

Appuyer Sur Le Bouton Ajouter Au Panier
    Wait Until Page Contains Element    accessibility_id=Ajouter au panier
    Click Element                       accessibility_id=Ajouter au panier

Vérifier Que Le Panier Contient Légume
    [Arguments]    ${nom}    ${quantite}
    # À compléter : implémenter la vérification réelle dans l'IHM ou via un retour API
    Log    Vérification du panier : ${nom} x ${quantite}

Appuyer Sur Le Bouton Passer Commande
    Wait Until Page Contains Element    accessibility_id=Passer commande
    Click Element                       accessibility_id=Passer commande

Vérifier Commande Créée Avec Statut
    [Arguments]    ${statut}
    # À compléter : implémenter la vérification réelle dans l'IHM ou via un retour API
    Log    Vérification de la commande avec statut : ${statut}

*** Test Cases ***
Acheteur Peut Créer Un Panier Et Passer Commande
    [Tags]    acheteur    panier    commande

    # Préparer les données : réinitialiser et insérer un légume de test
    Firebase.Purge Test Vegetables
    ${veg_result}=    Firebase.Insert Test Data    vegetables    courgette-1    {"name": "Courgette", "description": "Courgette test", "latitude": 48.85, "longitude": 2.35, "deliveryRadiusKm": 5, "priceCents": 350, "quantityAvailable": 10, "availabilityType": "available", "active": true}
    Log    ${veg_result}

    Appuyer Sur Le Bouton Acheter Des Légumes
    Vérifier Présence Du Légume Avec Titre    Courgette

    Cliquer Sur Le Légume Avec Titre          Courgette
    Vérifier Page Détail Du Légume            Courgette

    Appuyer Sur Le Bouton Ajouter Au Panier
    Vérifier Que Le Panier Contient Légume    Courgette    1

    Appuyer Sur Le Bouton Passer Commande
    Vérifier Commande Créée Avec Statut       pending
    
Afficher Les Légumes Dès L’Entrée Acheteur
    [Tags]    acheteur    affichage
    Firebase.Purge Test Vegetables
    Firebase.Insert Test Data    vegetables    carotte-1    {"name": "Carotte", "description": "Carotte test", "latitude": 48.85, "longitude": 2.35, "deliveryRadiusKm": 5, "priceCents": 350, "quantityAvailable": 10, "availabilityType": "available", "active": true}

    Appuyer Sur Le Bouton Acheter Des Légumes
    Vérifier Présence Du Légume Avec Titre    Carotte

Afficher Carte Et Liste Des Légumes Proches
    [Tags]    acheteur    carte
    Firebase.Purge Test Vegetables
    Firebase.Insert Test Data    vegetables    poireau-1    {"name": "Poireau", "description": "Poireau test", "latitude": 48.85, "longitude": 2.35, "deliveryRadiusKm": 4, "priceCents": 350, "quantityAvailable": 10, "availabilityType": "available", "active": true}

    Appuyer Sur Le Bouton Acheter Des Légumes
    Aller Dans L’Onglet Carte
    Vérifier Présence Du Marqueur Avec Titre    Poireau

Sélection De Légume Et Détails
    [Tags]    acheteur    détails
    Firebase.Purge Test Vegetables
    Firebase.Insert Test Data    vegetables    tomate-1    {"name": "Tomate", "description": "Tomate test", "latitude": 48.85, "longitude": 2.35, "deliveryRadiusKm": 5, "priceCents": 350, "quantityAvailable": 10, "availabilityType": "available", "active": true}

    Appuyer Sur Le Bouton Acheter Des Légumes
    Vérifier Présence Du Légume Avec Titre    Tomate
    Cliquer Sur Le Légume Avec Titre    Tomate
    Vérifier Page Détail Du Légume    Tomate

Affichage Légumes À Portée De Livraison
    [Tags]    acheteur    filtrage
    Firebase.Purge Test Vegetables
    Firebase.Insert Test Data    vegetables    betterave-1    {"name": "Betterave", "description": "Betterave test", "latitude": 48.8500, "longitude": 2.3500, "deliveryRadiusKm": 3, "priceCents": 350, "quantityAvailable": 10, "availabilityType": "available", "active": true}
    Firebase.Insert Test Data    vegetables    pasteque-1    {"name": "Pastèque", "description": "Pastèque test", "latitude": 48.9000, "longitude": 2.4000, "deliveryRadiusKm": 3, "priceCents": 350, "quantityAvailable": 10, "availabilityType": "available", "active": true}

    Définir Position De Livraison    48.8510    2.3510
    Appuyer Sur Le Bouton Acheter Des Légumes
    Vérifier Présence Du Légume Avec Titre    Betterave
    Vérifier Absence Du Légume Avec Titre    Pastèque
