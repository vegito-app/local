*** Settings ***
Library    Firebase.py
Library    AppiumLibrary
Resource    keywords.robot

*** Keywords ***
Purge Test Vegetables
    ${result}=    Firebase.purge_test_vegetables
    Log    ${result}

Ajouter Une Photo
    [Arguments]    ${image}        ${clickable_index}
    Wait Until Page Contains Element    accessibility_id=Ajouter une photo
    Click Element                       accessibility_id=Ajouter une photo
    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Photos"]
    Click Element                       xpath=//android.widget.TextView[@text="Photos"]
    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[1]
    Click Element                       xpath=(//android.widget.RelativeLayout)[1]
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[${clickable_index}]
    Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[${clickable_index}]

    ${value}=    Evaluate    ${clickable_index} - 1        
    Wait Until Page Contains Element    accessibility_id=set-main-image-${image}-${value}
    Page Should Contain Element    accessibility_id=delete-image-${image}-${value}, Supprimer cette photo

Ajouter La Premiere Photo
    [Arguments]    ${image}        ${clickable_index}
    Wait Until Page Contains Element    accessibility_id=Choisir une photo
    Click Element                   accessibility_id=Choisir une photo
    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Photos"]
    Click Element                       xpath=//android.widget.TextView[@text="Photos"]
    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[1]
    Click Element                       xpath=(//android.widget.RelativeLayout)[1]
    
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[${clickable_index}]
    Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[${clickable_index}]
    ${value}=    Evaluate    ${clickable_index} - 1        
    Wait Until Page Contains Element    accessibility_id=delete-image-${image}-${value}, Supprimer cette photo

Choisir Une Photo Depuis L’Interface
    [Arguments]    ${clickable_index}    ${image}

    ${add_button_present}=    Run Keyword And Return Status    Wait Until Page Contains Element    accessibility_id=add-vegetable-button    timeout=3s
    Run Keyword If    ${add_button_present}    Click Element    accessibility_id=add-vegetable-button

    Ajouter La Premiere Photo    ${clickable_index}    ${image}        

Ajouter Une Photo Depuis L’Interface
    [Arguments]    ${clickable_index}    ${image}

    ${add_button_present}=    Run Keyword And Return Status    Wait Until Page Contains Element    accessibility_id=add-vegetable-button    timeout=3s
    Run Keyword If    ${add_button_present}    Click Element    accessibility_id=add-vegetable-button

    Wait Until Page Contains Element    accessibility_id=Ajouter une photo
    Click Element    accessibility_id=Ajouter une photo
    Ajouter La Premiere Photo    ${clickable_index}    ${image}        

Vendre Un Légume Depuis L’Interface
    [Arguments]    ${nom}    ${description}    ${poids}    ${prix}    ${clickable_index}    ${image}
    Click Element    accessibility_id=🧺 Vendre mes légumes
    # Vérifie que les boutons de gestion ne sont pas visibles lors de la première saisie
    Page Should Not Contain Element    accessibility_id=Supprimer l’annonce
    Page Should Not Contain Element    accessibility_id=Rendre invisible

    Choisir Une Photo Depuis L’Interface    ${clickable_index}  ${image}

    Click Element    accessibility_id=À l’unité
    Wait Until Page Contains Element    accessibility_id=Au poids (€/kg)
    Click Element    accessibility_id=Au poids (€/kg)
    
    Fill Field By Index    1            ${nom}
    Fill Field By Index    2            ${description}
    Fill Field By Index    3            ${poids}
    Fill Field By Index    4            ${prix}

    Scroll And Tap Vegetable Upload Register Button
    Sleep    2s
    
Vérifier Légume Vendu Au Poids Présent
    [Arguments]    ${nom}    ${poids}    ${prix}    ${description}
    ${prix_euro}=    Evaluate    str(${prix}) + "€ / Kg"
    ${texte}=    Set Variable    ${nom}\n${prix_euro}\nReste : ${poids} Kg\n${description}
    Wait Until Page Contains Element    accessibility_id=${texte}

Vérifier Légume Vendu À L’Unité Présent
    [Arguments]    ${nom}    ${prix}    ${description}
    ${prix_euro}=    Evaluate    str(${prix} / 100) + "€"
    ${texte}=    Set Variable    ${nom}\n${prix_euro} à l'unité\n${description}
    Wait Until Page Contains Element    accessibility_id=${texte}

Verifier Gestion légumes
    # Vérifie la présence des boutons de gestion
    Page Should Contain Element    accessibility_id=Supprimer l’annonce
    Page Should Contain Element    accessibility_id=Rendre invisible

Scroll And Tap Vegetable Upload Register Button
    Scroll And Tap    accessibility_id=Enregistrer
    Wait Until Page Contains Element    accessibility_id=vegetable-upload-success\nLégume ajouté avec succès

Changer Type Vente Au Poids
    Changer Type Vente    À l’unité    Au poids (€/kg)

Changer Type Vente À L’Unité
    Changer Type Vente    Au poids (€/kg)    À l’unité

Changer Type Vente
    [Arguments]    ${type_vente}  ${type_vente_suivant}
    Wait Until Page Contains Element    accessibility_id=${type_vente}
    Click Element    accessibility_id=${type_vente}
    Wait Until Page Contains Element    accessibility_id=${type_vente_suivant}
    Click Element    accessibility_id=${type_vente_suivant}