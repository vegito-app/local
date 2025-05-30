*** Settings ***
Resource         ../resources/keywords.robot
Library           AppiumLibrary

*** Variables ***
${REMOTE_URL}     http://android-studio:4723
${PLATFORM_NAME}  Android
${APP_PACKAGE}    dev.mobile.app.android
${APP_ACTIVITY}   .MainActivity

*** Test Cases ***
Ajouter une carotte depuis l’interface
    Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    automationName=UiAutomator2    appPackage=${APP_PACKAGE}    appActivity=${APP_ACTIVITY}    noReset=true    dontStopAppOnReset=true
    Handle Permission Popup
    Log Source

    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element    accessibility_id=🧺 Vendre mes légumes

    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=Choisir une photo
    Click Element    accessibility_id=Choisir une photo

    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Photos"]
    Click Element                       xpath=//android.widget.TextView[@text="Photos"]
    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[1]
    Click Element                       xpath=(//android.widget.RelativeLayout)[1]
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[2]
    Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[2]

    # Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=Ajouter une photo
    # Click Element    accessibility_id=Ajouter une photo

    # # Ajout deuxième image
    # Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Photos"]
    # Click Element                       xpath=//android.widget.TextView[@text="Photos"]
    # Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    # Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[2]
    # Click Element                       xpath=(//android.widget.RelativeLayout)[2]
    # Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[3]
    # Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[3] 

    # Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=Ajouter une photo
    # Click Element    accessibility_id=Ajouter une photo

    # # Ajout troisième image
    # Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Photos"]
    # Click Element                       xpath=//android.widget.TextView[@text="Photos"]
    # Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    # Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[2]
    # Click Element                       xpath=(//android.widget.RelativeLayout)[2]
    # Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[4]
    # Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[4]

    # # Suppression de la deuxieme image sélectionnée
    # Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=Supprimer photo 2, Supprimer cette photo
    # Click Element                   accessibility_id=Supprimer photo 2, Supprimer cette photo

    Wait Until Keyword Succeeds    10x    1s    Page Should Contain Element    xpath=(//android.widget.EditText)[1]

    Click Element    xpath=//android.widget.Button[@content-desc="À l’unité"]
    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    xpath=//android.widget.Button[@content-desc="Au poids (€/kg)"]
    Click Element    xpath=//android.widget.Button[@content-desc="Au poids (€/kg)"]

    Fill Field By Index    1    Carotte
    Fill Field By Index    2    Fraîche du jardin
    Fill Field By Index    3    500
    Fill Field By Index    4    250

    Swipe Until Element Is Visible    xpath=//android.widget.Button[@content-desc="Enregistrer"]

    Wait Until Keyword Succeeds    10x    1s    Page Should Contain Element    xpath=//android.widget.TextView[contains(@text, "Légume ajouté")]


Ajouter un légume vendu au poids
    Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    automationName=UiAutomator2    appPackage=com.example.car2go    appActivity=.MainActivity    noReset=true    dontStopAppOnReset=true
    # Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    automationName=UiAutomator2    app=/workspaces/refactored-winner/application/mobile/build/app/outputs/flutter-apk/app-debug.apk    autoGrantPermissions=true
    
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                       accessibility_id=🧺 Vendre mes légumes

    Wait Until Page Contains Element    accessibility_id=Choisir une photo
    Click Element                       accessibility_id=Choisir une photo

    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=Ajouter une photo
    Click Element                   accessibility_id=Ajouter une photo

    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[2]
    Click Element                       xpath=(//android.widget.RelativeLayout)[2]
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@resource-id="com.google.android.apps.photos:id/image"])[2]
    Click Element                       xpath=(//android.view.ViewGroup[@resource-id="com.google.android.apps.photos:id/image"])[2]
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[2]
    Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[2]

    Input Text    xpath=(//android.widget.EditText)[1]    Tomate
    Input Text    xpath=(//android.widget.EditText)[2]    Fraîchement récoltée
    Click Element    accessibility_id=Au poids (€/kg)
    Input Text    xpath=(//android.widget.EditText)[3]    750
    Input Text    xpath=(//android.widget.EditText)[4]    450

    Scroll To Element    accessibility_id=Enregistrer
    Click Element        accessibility_id=Enregistrer
    Sleep    2s

Ajouter un légume vendu à l’unité
    # Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    automationName=UiAutomator2    app=/workspaces/refactored-winner/application/mobile/build/app/outputs/flutter-apk/app-debug.apk    autoGrantPermissions=true
    Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    automationName=UiAutomator2    appPackage=com.example.car2go    appActivity=.MainActivity    noReset=true    dontStopAppOnReset=true
    Wait Until Page Contains Element    accessibility_id=🧺 Vendre mes légumes
    Click Element                       accessibility_id=🧺 Vendre mes légumes

    Wait Until Page Contains Element    accessibility_id=Choisir une photo
    Click Element                       accessibility_id=Choisir une photo

    Wait Until Keyword Succeeds    10x    1s    Wait Until Page Contains Element    accessibility_id=Ajouter une photo
    Click Element                   accessibility_id=Ajouter une photo

    Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Device folders"]
    Wait Until Page Contains Element    xpath=(//android.widget.RelativeLayout)[2]
    Click Element                       xpath=(//android.widget.RelativeLayout)[2]
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@resource-id="com.google.android.apps.photos:id/image"])[2]
    Click Element                       xpath=(//android.view.ViewGroup[@resource-id="com.google.android.apps.photos:id/image"])[2]
    Wait Until Page Contains Element    xpath=(//android.view.ViewGroup[@clickable="true"])[2]
    Click Element                       xpath=(//android.view.ViewGroup[@clickable="true"])[2]

    Input Text    xpath=(//android.widget.EditText)[1]    Citrouille
    Input Text    xpath=(//android.widget.EditText)[2]    Belle pièce pour Halloween
    Click Element    accessibility_id=À l’unité
    Input Text    xpath=(//android.widget.EditText)[3]    1000
    Input Text    xpath=(//android.widget.EditText)[4]    300


    Scroll To Element    accessibility_id=Enregistrer
    Click Element        accessibility_id=Enregistrer
    Sleep    2s