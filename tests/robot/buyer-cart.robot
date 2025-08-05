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
Acheteur Peut Ajouter Un Légume Au Panier
    [Tags]    panier
    Purge Test Vegetables
    ${_}=    Firebase.create_test_vegetable    name=Tomate    doc_id=tomate-id    lat=48.8    lng=2.3
    Lancer Application En Mode Acheteur
    Aller Sur La Page D'Achat
    Choisir Légume Tomate
    Ajouter Au Panier
    Vérifier Panier Contient Tomate Avec Quantité 1 Et Prix 3.5