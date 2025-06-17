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

    Vendre Un Légume Depuis L’Interface    Aubergine    Fraîche    300    2   2     aubergine.jpg
    Vendre Un Légume Depuis L’Interface    Courgette    Très verte    500    2.50   4   courgette.jpg

    Vérifier Légume Vendu Au Poids Présent    Aubergine    300    2.0    Fraîche
    Vérifier Légume Vendu Au Poids Présent    Courgette    500    2.5    Très verte

Modification D’un Légume Depuis La Galerie
    [Documentation]    Vérifie qu’un légume peut être modifié via sa vignette.
    Push Test Image    poivron.jpg
    Vendre Un Légume Depuis L’Interface    Poivron    Bio et rouge    400    3   2   poivron.jpg
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
    Element Text Should Be              xpath=(//android.widget.EditText)[3]    400
    Scroll To    xpath=(//android.widget.EditText)[4]
    Element Text Should Be              xpath=(//android.widget.EditText)[4]    300
    Scroll To    accessibility_id=Enregistrer

Changement De Type De Vente D’un Légume Après Enregistrement
    [Documentation]    Vérifie qu’un légume peut être édité après avoir été enregistré.
    Push Test Image    concombre.jpg
    Push Test Image    concombre-2.jpg
    Vendre Un Légume Depuis L’Interface    Concombre    Croquant    600    400   2   concombre.jpg
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes

    Vérifier Légume Vendu Au Poids Présent    Concombre    600    400    Croquant
    Click Element    accessibility_id=Concombre\n600g - 4.0€\nCroquant
    Ajouter Une Photo Depuis L’Interface    3  concombre-2.jpg

    Click Element    accessibility_id=dropdown-sale-type\nAu poids (€/kg)
    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=À l’unité
    Click Element    accessibility_id=À l’unité

    Refill Field By Index    2            Très croquant
    Refill Field By Index    3            230   
    Scroll And Tap        accessibility_id=Enregistrer
    Vérifier Légume Vendu À L’Unité Présent    Concombre    230    Très croquant
