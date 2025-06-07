*** Settings ***
Library    Firebase.py
Library    AppiumLibrary
Resource    keywords.robot

*** Keywords ***
Purge Test Vegetables
    ${result}=    Firebase.purge_test_vegetables
    Log    ${result}

Ajouter Une Photo Depuis L’Interface
    [Arguments]    ${clickable_index}    ${image}

    Click Element    accessibility_id=🧺 Vendre mes légumes

    ${add_button_present}=    Run Keyword And Return Status    Wait Until Page Contains Element    accessibility_id=add-vegetable-button    timeout=3s
    Run Keyword If    ${add_button_present}    Click Element    accessibility_id=add-vegetable-button

    Wait Until Page Contains Element    accessibility_id=Choisir une photo
    Click Element    accessibility_id=Choisir une photo

    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Photos"]
    Click Element                       xpath=//android.widget.TextView[@text="Photos"]
    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[1]
    Click Element                       xpath=(//android.widget.RelativeLayout)[1]
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[${clickable_index}]
    Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[${clickable_index}]

    Wait Until Page Contains Element    xpath=(//android.widget.EditText)[1]


Vendre Un Légume Depuis L’Interface
    [Arguments]    ${nom}    ${description}    ${poids}    ${prix}    ${clickable_index}    ${image}
    Ajouter Une Photo Depuis L’Interface    ${clickable_index}  ${image}

    Click Element    accessibility_id=dropdown-sale-type\nÀ l’unité
    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=Au poids (€/kg)
    Click Element    accessibility_id=Au poids (€/kg)
    
    Fill Field By Index    1            ${nom}
    Fill Field By Index    2            ${description}
    Fill Field By Index    3            ${poids}
    Fill Field By Index    4            ${prix}

    Swipe Until Element Is Visible    accessibility_id=Enregistrer
    Sleep    2s
Vérifier Légume Présent
    [Arguments]    ${nom}    ${poids}    ${prix}    ${description}
    ${prix_euro}=    Evaluate    str(${prix} / 100) + "€"
    ${texte}=    Set Variable    ${nom}\n${poids}g - ${prix_euro}\n${description}
    Wait Until Page Contains Element    accessibility_id=${texte}