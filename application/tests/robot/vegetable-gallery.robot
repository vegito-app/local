*** Settings ***
Library           AppiumLibrary
Library           Collections

Resource         ../resources/keywords.robot
Resource         ../resources/vegetable.robot

Test Setup        Reset State And Return Home
Test Teardown     Capture Screenshot On Failure

*** Variables ***
${REMOTE_URL}     http://android-studio:4723
${PLATFORM_NAME}  Android
${APP_PACKAGE}    dev.mobile.app.android
${APP_ACTIVITY}   .MainActivity

*** Test Cases ***
Galerie Contient Plusieurs Légumes
    [Documentation]    Vérifie que plusieurs légumes ajoutés apparaissent dans la galerie.
    Push Test Image    aubergine.jpg
    Push Test Image    courgette.jpg

    Vendre Un Légume Depuis La Page D'Enregistrement     Aubergine    Fraîche    300    2   2     aubergine.jpg
    Vendre Un Légume Depuis La Page D'Enregistrement     Courgette    Très verte    500    2.50   4   courgette.jpg

    Vérifier Légume Vendu Au Poids Présent    Aubergine    300    2.0    Fraîche
    Vérifier Légume Vendu Au Poids Présent    Courgette    500    2.5    Très verte

Modification D’un Légume Depuis La Galerie
    [Documentation]    Vérifie qu’un légume peut être modifié via sa vignette.
    Push Test Image    poivron.jpg
    Vendre Un Légume Depuis La Page D'Enregistrement     Poivron    Bio et rouge    400    3   2   poivron.jpg
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes

    Vérifier Légume Vendu Au Poids Présent    Poivron    400    3.0    Bio et rouge
    Click Element    accessibility_id=Poivron\n3.0€ / Kg\nReste : 400 Kg\nBio et rouge

    Wait Until Page Contains Element    xpath=//android.widget.ImageView[contains(@content-desc, "poivron.jpg")]    timeout=10s
    Wait Until Page Contains Element    xpath=(//android.widget.EditText)[1]
    
    Element Text Should Be              xpath=(//android.widget.EditText)[1]    Poivron
    Scroll To    xpath=(//android.widget.EditText)[2]
    Element Text Should Be              xpath=(//android.widget.EditText)[2]    Bio et rouge
    Scroll To    xpath=(//android.widget.EditText)[3]
    Element Text Should Be              xpath=(//android.widget.EditText)[3]    400000
    Element Text Should Be              xpath=(//android.widget.EditText)[4]    400
    Scroll To    xpath=(//android.widget.EditText)[5]
    Element Text Should Be              xpath=(//android.widget.EditText)[5]    3.00
    Scroll To    accessibility_id=Enregistrer

Changement De Type De Vente D’un Légume Après Enregistrement
    [Documentation]    Vérifie qu’un légume peut être édité après avoir été enregistré.
    Push Test Image    concombre.jpg
    Push Test Image    concombre-2.jpg
    Vendre Un Légume Depuis La Page D'Enregistrement     Concombre    Croquant    600    4.0   2   concombre.jpg
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes

    Vérifier Légume Vendu Au Poids Présent    Concombre    600    4.0    Croquant
    Click Element    accessibility_id=Concombre\n4.0€ / Kg\nReste : 600 Kg\nCroquant
    Ajouter Une Photo    3

    Wait Until Page Contains Element    accessibility_id=Au poids (€/kg)
    Click Element    accessibility_id=Au poids (€/kg)
    Wait Until Page Contains Element    accessibility_id=À l’unité
    Click Element    accessibility_id=À l’unité

    Scroll To    xpath=(//android.widget.EditText)[2]
    Refill Field By Index    2            Très croquant
    Scroll To    xpath=(//android.widget.EditText)[3]
    Refill Field By Index    3            300   
    Refill Field By Index    4            2.30   
    Scroll And Tap        accessibility_id=Enregistrer
    Vérifier Légume Vendu À L’Unité Présent    Concombre    2.3    Reste : 300 pièces\nTrès croquant
