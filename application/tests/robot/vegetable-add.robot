*** Settings ***
Library          AppiumLibrary
Resource         ../resources/keywords.robot
Library           AppiumLibrary
Library           Collections
# Suite Setup      Firebase.purge_test_vegetables
Test Setup        Reset State And Return Home

*** Variables ***
${REMOTE_URL}     http://android-studio:4723
${PLATFORM_NAME}  Android
${APP_PACKAGE}    dev.mobile.app.android
${APP_ACTIVITY}   .MainActivity

*** Test Cases ***
Ajouter une carotte depuis l’interface
    Push Test Image    carrotes.jpeg

    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes

    Ajouter La Premiere Photo    carrotes    2

    Changer Type Vente Au Poids

    Fill Field By Index    1    Carotte
    Fill Field By Index    2    Fraîche du jardin
    Fill Field By Index    3    0.500
    Fill Field By Index    4    2.50

    Scroll And Tap Vegetable Upload Register Button

    # Go Back
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                       accessibility_id=🧺 Vendre mes légumes
    Wait Until Keyword Succeeds    10x    1s    Page Should Contain Element    accessibility_id=Carotte\n2.5€ / Kg\nReste : 500 g\nFraîche du jardin
    Go Back

Ajouter un chouchou avec plusieurs images depuis l’interface
    Push Test Image    chouchou.jpg
    Push Test Image    chouchou-2.jpeg
    Push Test Image    chouchou-3.jpeg
    Push Test Image    chouchou-4.jpeg

    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes

    Ajouter La Premiere Photo        chouchou  2
    Ajouter Une Photo    chouchou-2  3
    Ajouter Une Photo    chouchou-3  4

    # Suppression de la deuxieme image sélectionnée
    Wait Until Page Contains Element    accessibility_id=delete-image-chouchou-3-3, Supprimer cette photo
    Click Element                   accessibility_id=delete-image-chouchou-3-3, Supprimer cette photo

    Wait Until Keyword Succeeds    10x    1s    Page Should Contain Element    xpath=(//android.widget.EditText)[1]

    Changer Type Vente Au Poids

    Fill Field By Index    1    Chouchou
    Fill Field By Index    2    Fraîche du jardin
    Fill Field By Index    3    0.500
    Fill Field By Index    4    2.50

    Scroll And Tap Vegetable Upload Register Button

    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                       accessibility_id=🧺 Vendre mes légumes
    Wait Until Keyword Succeeds    10x    1s    Page Should Contain Element    accessibility_id=Chouchou\n2.5€ / Kg\nReste : 500 g\nFraîche du jardin

Ajouter un légume vendu au poids
    Push Test Image    tomate.jpg
    Push Test Image    tomate-2.jpg
    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                       accessibility_id=🧺 Vendre mes légumes

    Ajouter La Premiere Photo    tomate    2

    Log Source
    
    Changer Type Vente Au Poids

    Fill Field By Index    1    Tomate
    Fill Field By Index    2    Fraîchement récoltée
    Fill Field By Index    3    0.750
    Fill Field By Index    4    4.50

    Scroll And Tap Vegetable Upload Register Button
    Sleep    2s

Ajouter un légume vendu à l’unité
    Push Test Image    citrouille.jpg
    Push Test Image    citrouille-2.jpg
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                       accessibility_id=🧺 Vendre mes légumes

    Ajouter La Premiere Photo   citrouille  2

    Fill Field By Index    1    Citrouille
    Fill Field By Index    2    Belle pièce pour Halloween

    Changer Type Vente Au Poids

    Fill Field By Index    3    1.000
    Fill Field By Index    4    3.00
    
    Scroll And Tap Vegetable Upload Register Button
    Sleep    2s

Sélection d’une image principale via l’étoile
    Push Test Image    patate-2.jpg
    Push Test Image    patate-3.jpg
    Push Test Image    patate-4.jpg

    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                   accessibility_id=🧺 Vendre mes légumes    

    Ajouter La Premiere Photo   patate-2  2

    Ajouter Une Photo    patate-3  3

    Ajouter Une Photo    patate-4  4

    Wait Until Page Contains Element    accessibility_id=delete-image-patate-4-3, Supprimer cette photo
    Click Element    locator=accessibility_id=set-main-image-patate-4-3
    Page Should Contain Element         accessibility_id=set-main-image-patate-2-2
    Page Should Contain Element         accessibility_id=delete-image-patate-4-1, Supprimer cette photo
    Page Should Contain Element         accessibility_id=delete-image-patate-3-3, Supprimer cette photo

    # Click Element                       accessibility_id=delete-image-patate-2-2, Supprimer cette photo


    Fill Field By Index    1    Patate
    Fill Field By Index    2    Fraîche et bio
    Fill Field By Index    3    1.000
    Fill Field By Index    4    2.00

    Scroll And Tap Vegetable Upload Register Button

    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                       accessibility_id=🧺 Vendre mes légumes
    Wait Until Page Contains Element    accessibility_id=Patate\n2.0€ / unité\nReste : 1000 pièces\nFraîche et bio
    Click Element                       accessibility_id=Patate\n2.0€ / unité\nReste : 1000 pièces\nFraîche et bio

    Wait Until Page Contains Element    accessibility_id=set-main-image-patate-2-2
    Click Element    locator=accessibility_id=set-main-image-patate-2-2
    Wait Until Page Contains Element    accessibility_id=delete-image-patate-2-1, Supprimer cette photo
    Page Should Contain Element         accessibility_id=delete-image-patate-2-1, Supprimer cette photo
    Page Should Contain Element         accessibility_id=set-main-image-patate-4-2
    Page Should Contain Element         accessibility_id=set-main-image-patate-3-3
    Click Element    locator=accessibility_id=set-main-image-patate-3-3
    Scroll And Tap Vegetable Upload Register Button
    Wait Until Page Contains Element    accessibility_id=Patate\n2.0€ / unité\nReste : 1000 pièces\nFraîche et bio
    Click Element                       accessibility_id=Patate\n2.0€ / unité\nReste : 1000 pièces\nFraîche et bio
    Wait Until Page Contains Element    accessibility_id=delete-image-patate-3-1, Supprimer cette photo
    Page Should Contain Element         accessibility_id=set-main-image-patate-2-2
    Page Should Contain Element         accessibility_id=set-main-image-patate-4-3