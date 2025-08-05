*** Settings ***
Library           AppiumLibrary
Library           Collections

Resource         ../resources/keywords.robot
Resource         ../resources/vegetable.robot
Resource         ../resources/vegetable_management.robot

Test Setup        Reset State And Return Home
Test Teardown     Capture Screenshot On Failure

*** Variables ***
${REMOTE_URL}     http://android-studio:4723
${PLATFORM_NAME}  Android
${APP_PACKAGE}    dev.vegito.app.android
${APP_ACTIVITY}   .MainActivity

*** Test Cases ***

Vérifie Présence Boutons En Mode Création
    [Documentation]    Vérifie qu'à la création initiale d'une annonce, les boutons de gestion ne sont pas présents.
    Push Test Image    radis.jpg
    Vendre Un Légume Depuis La Page D'Enregistrement    Radis    Très croquant    300    180   2   radis.jpg
    Page Should Not Contain Element    accessibility_id=Supprimer
    Page Should Not Contain Element    xpath=//android.widget.Switch

Test Masquage Simple D'Une Annonce
    [Documentation]    Vérifie uniquement la désactivation d'une annonce.
    Push Test Image    poireaux.jpg
    Vendre Un Légume Depuis La Page D'Enregistrement    Poireaux    Bien frais    1000    350   2   poireaux.jpg
    Click Element    accessibility_id=🧺 Vendre mes légumes
    Wait Until Page Contains Element    accessibility_id=Poireaux\n1000g - 3.5€\nBien frais
    Click Element    accessibility_id=Poireaux\n1000g - 3.5€\nBien frais
    Page Should Contain Element    xpath=//android.widget.Switch[@checked='true']
    Click Element    xpath=//android.widget.Switch
    Wait Until Keyword Succeeds    10x    1s    Page Should Not Contain Element    accessibility_id=Poireaux\n1000g - 3.5€\nBien frais

Test Suppression Simple D'Une Annonce
    [Documentation]    Vérifie uniquement la suppression d'une annonce.
    Push Test Image    manioc.jpeg
    Vendre Un Légume Depuis La Page D'Enregistrement    Manioc    Bien crémeux    500    220   2   manioc.jpeg
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes
    Wait Until Page Contains Element    accessibility_id=Manioc\n500g - 2.2€\nBien crémeux
    Click Element    accessibility_id=Manioc\n500g - 2.2€\nBien crémeux
    Wait Until Page Contains Element    accessibility_id=Supprimer
    Click Element    accessibility_id=Supprimer
    Wait Until Page Contains Element    accessibility_id=Je comprends que cette action est irréversible.
    Click Element    xpath=//android.widget.CheckBox
    Click Element    accessibility_id=Supprimer
    Wait Until Keyword Succeeds    10x    1s    Page Should Contain Element    accessibility_id=Ajouter un légume
Cycle Complet De Gestion D'Annonce
    [Documentation]    Vérifie l'ensemble du cycle de gestion (création, masquage, réactivation, suppression).
    Push Test Image    tomate.jpg
    Vendre Un Légume Depuis La Page D'Enregistrement    Tomate    Bien rouge    800    250   2   tomate.jpg
    Scroll And Tap Vegetable Upload Register Button
    Click Element    accessibility_id=Tomate\n800g - 2.5€\nBien rouge
    Page Should Contain Element    accessibility_id=Supprimer
    Page Should Contain Element    xpath=//android.widget.Switch[@checked='true']
    Click Element    xpath=//android.widget.Switch
    Wait Until Keyword Succeeds    10x    1s    Page Should Not Contain Element    accessibility_id=Tomate\n800g - 2.5€\nBien rouge
    Click Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=Tomate\n800g - 2.5€\nBien rouge
    Page Should Contain Element    xpath=//android.widget.Switch[@checked='false']
    Click Element    xpath=//android.widget.Switch
    Wait Until Page Contains Element    accessibility_id=Tomate\n800g - 2.5€\nBien rouge
    Click Element    accessibility_id=Supprimer
    Wait Until Page Contains Element    accessibility_id=Je comprends que cette action est irréversible.
    Click Element    xpath=//android.widget.CheckBox
    Click Element    accessibility_id=Supprimer
    Wait Until Keyword Succeeds    10x    1s    Page Should Not Contain Element    accessibility_id=Tomate\n800g - 2.5€\nBien rouge