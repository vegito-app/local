*** Settings ***
Library          AppiumLibrary
Resource         ../resources/keywords.robot
Resource         ../resources/vegetable.robot
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

Galerie Contient Plusieurs Légumes
    [Documentation]    Vérifie que plusieurs légumes ajoutés apparaissent dans la galerie.
    Push Test Image    aubergine.jpg
    Push Test Image    courgette.jpg

    Vendre Un Légume Depuis L’Interface    Aubergine    Fraîche    300    200   2     aubergine.jpg
    Vendre Un Légume Depuis L’Interface    Courgette    Très verte    500    250   4   courgette.jpg

    Vérifier Légume Présent    Aubergine    300    200    Fraîche
    Vérifier Légume Présent    Courgette    500    250    Très verte     

Modification D’un Légume Depuis La Galerie
    [Documentation]    Vérifie qu’un légume peut être modifié via sa vignette.
    Push Test Image    poivron.jpg
    Vendre Un Légume Depuis L’Interface    Poivron    Bio et rouge    400    300   2   poivron.jpg
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes

    Vérifier Légume Présent    Poivron    400    300    Bio et rouge
    Click Element    accessibility_id=Poivron\n400g - 3.0€\nBio et rouge

    Wait Until Page Contains Element    xpath=(//android.widget.EditText)[1]
    Element Text Should Be              xpath=(//android.widget.EditText)[1]    Poivron
    Element Text Should Be              xpath=(//android.widget.EditText)[2]    Bio et rouge
    Element Text Should Be              xpath=(//android.widget.EditText)[3]    400
    Element Text Should Be              xpath=(//android.widget.EditText)[4]    300
    Wait Until Page Contains Element    xpath=//android.widget.ImageView[contains(@content-desc, "poivron.jpg")]    timeout=10s
