*** Settings ***
Library           AppiumLibrary
Library           Collections

Resource         ../resources/keywords.robot
Resource         ../resources/firebase_keywords.robot
Resource         ../resources/vegetable.robot

Test Setup        Reset State And Return Home
Test Teardown     Capture Screenshot On Failure

*** Variables ***
${REMOTE_URL}     http://android-studio:4723
${PLATFORM_NAME}  Android
${APP_PACKAGE}    dev.mobile.app.android
${APP_ACTIVITY}   .MainActivity

*** Test Cases ***
Afficher Les Légumes Dès L’Entrée Acheteur
    [Tags]    acheteur    affichage
    Purge Test Vegetables
    Firebase.Create Test Vegetable    name=Carotte    doc_id=carotte-1    lat=48.85    lng=2.35    deliveryRadiusKm=5
    Lancer Application En Mode Acheteur
    Appuyer Sur Le Bouton Acheter Des Légumes
    Vérifier Présence Du Légume Avec Titre    Carotte

Afficher Carte Et Liste Des Légumes Proches
    [Tags]    acheteur    carte
    Firebase.Create Test Vegetable    name=Poireau    doc_id=poireau-1    lat=48.85    lng=2.35    deliveryRadiusKm=4
    Lancer Application En Mode Acheteur
    Appuyer Sur Le Bouton Acheter Des Légumes
    Aller Dans L’Onglet Carte
    Vérifier Présence Du Marqueur Avec Titre    Poireau

Sélection De Légume Et Détails
    [Tags]    acheteur    détails
    Firebase.Create Test Vegetable    name=Tomate    doc_id=tomate-1    lat=48.85    lng=2.35    deliveryRadiusKm=5
    Lancer Application En Mode Acheteur
    Appuyer Sur Le Bouton Acheter Des Légumes
    Vérifier Présence Du Légume Avec Titre    Tomate
    Cliquer Sur Le Légume Avec Titre    Tomate
    Vérifier Page Détail Du Légume    Tomate

Affichage Légumes À Portée De Livraison
    [Tags]    acheteur    filtrage
    Firebase.Create Test Vegetable    name=Betterave    doc_id=betterave-1    lat=48.8500    lng=2.3500    deliveryRadiusKm=3
    Firebase.Create Test Vegetable    name=Pastèque    doc_id=pasteque-1    lat=48.9000    lng=2.4000    deliveryRadiusKm=3
    Lancer Application En Mode Acheteur
    Définir Position De Livraison    48.8510    2.3510
    Appuyer Sur Le Bouton Acheter Des Légumes
    Vérifier Présence Du Légume Avec Titre    Betterave
    Vérifier Absence Du Légume Avec Titre    Pastèque