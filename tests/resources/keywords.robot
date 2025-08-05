*** Settings ***
Library    AppiumLibrary
Library    Process
Resource         ../resources/vegetable.robot

*** Keywords ***
Fill Field By Index
    [Arguments]    ${index}    ${value}
    Scroll And Tap    xpath=(//android.widget.EditText)[${index}]
    Wait Until Keyword Succeeds    10x    1s    Input Text                     xpath=(//android.widget.EditText)[${index}]    ${value}
    Press Keycode                  66


Refill Field By Index
    [Arguments]    ${index}    ${value}
    Scroll And Tap    $locatorxpath=(//android.widget.EditText)[${index}]
    Clear Text                     xpath=(//android.widget.EditText)[${index}]
    Input Text                     xpath=(//android.widget.EditText)[${index}]    ${value}
    Press Keycode                  66

Handle Permission Popup
    Wait Until Keyword Succeeds    3x    1s    Run Keyword And Ignore Error    Click Element    id=com.android.permissioncontroller:id/permission_allow_button

Go To Home Page
    [Documentation]    Revient à l'écran d'accueil
    ${visible}=    Run Keyword And Return Status    Page Contains Back
    WHILE    ${visible}
        Click Element    xpath=//android.widget.Button[@content-desc="Back"]
        Sleep    0.5s
        ${visible}=    Run Keyword And Return Status    Page Contains Back
    END
    
Page Contains Back
    [Documentation]    Vérifie si le bouton de retour est visible
    Page Should Contain Element    xpath=//android.widget.Button[@content-desc="Back"]

Reset State And Return Home
    [Documentation]    Réinitialise l'état de l'application et revient à la page d'accueil.
    Reset Firestore And Storage Before Test
    Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    automationName=UiAutomator2    appPackage=${APP_PACKAGE}    appActivity=${APP_ACTIVITY}    noReset=true    dontStopAppOnReset=true
    Clear Pictures Folder
    Handle Permission Popup
    Go To Home Page

Purge Vegetables Collection
    [Documentation]    Supprime toutes les entrées de la collection de légumes dans Firebase.
    Firebase.purge_vegetables_collection

Remove Files From Device
    [Arguments]    ${file_pattern}
    Execute Adb Shell    rm -f ${file_pattern}

Clear Pictures Folder
    [Documentation]    Supprime toutes les images visibles dans /sdcard/Pictures.
    Execute Adb Shell    rm -rf /sdcard/Pictures/*

Push Test Image
    [Arguments]    ${image}
    [Documentation]    Copie une image donnée depuis le dépôt /sdcard/TestImagesDepot vers /sdcard/Pictures sur l'appareil Android.
    Log    Copie de /sdcard/TestImagesDepot/${image} vers /sdcard/Pictures/${image}
    Execute Adb Shell    cp /sdcard/TestImagesDepot/${image} /sdcard/Pictures/${image}
    Execute Adb Shell     am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file:///sdcard/Pictures/${image}" >/dev/null

Populate Pictures Folder With Selected Images
    [Arguments]    @{images}
    [Documentation]    Copie les images listées depuis le dépôt /sdcard/TestImagesDepot vers /sdcard/Pictures sur l'appareil Android.
    FOR    ${image}    IN    @{images}
        Log    Copie de /sdcard/TestImagesDepot/${image} vers /sdcard/Pictures/${image}
        Execute Adb Shell    cp /sdcard/TestImagesDepot/${image} /sdcard/Pictures/${image}
    END
Install APK
    [Arguments]    ${apk_path}
    Log    Installing APK from ${apk_path}
    Execute Adb Shell    pm install -r ${apk_path}

Scroll And Tap
    [Arguments]    ${locator}
    Scroll To    ${locator}
    Click Element    ${locator}
    Sleep    2s

Scroll To
    [Arguments]    ${locator}
    ${MAX_SWIPES}=    Set Variable    10
    FOR    ${index}    IN RANGE    ${MAX_SWIPES}
        ${isVisible}=    Run Keyword And Return Status    Element Should Be Visible    ${locator}
        Exit For Loop If    ${isVisible}
        Swipe    500    1600    500    400    800
    END
    Wait Until Element Is Visible    ${locator}    timeout=5s

Capture Screenshot On Failure
    Run Keyword And Ignore Error    Capture Page Screenshot
    Run Keyword And Ignore Error    Log Source
    Run Keyword And Ignore Error    Log Page Source
    Close All Applications

Select Combobox Option By Index
    [Arguments]    ${combobox_index}    ${option_index}
    [Documentation]    Sélectionne une option dans une combobox par index
    Wait Until Page Contains Element    xpath=(//android.widget.Button)[${combobox_index}]
    Click Element    xpath=(//android.widget.Button)[${combobox_index}]
    Wait Until Page Contains Element    xpath=(//android.widget.Button)[${option_index}]
    Click Element    xpath=(//android.widget.Button)[${option_index}]


# --- Ajout : Set Delivery Location pour Google Maps widget ---
Set Delivery Location
    [Arguments]    ${latitude}    ${longitude}    ${radius}
    [Documentation]    Définit la localisation de livraison via l'UI de la carte Google Maps.
    # Exemple d'implémentation : cliquer sur la carte ou remplir les champs si disponibles
    # TODO: Adapter au widget spécifique de ta carte
    Log    Sélection de la localisation latitude=${latitude}, longitude=${longitude}, radius=${radius}
    # Exemple : cliquer sur le widget carte pour positionner un marker
    # Click Element    xpath=//android.view.View[@content-desc="Map"]
    # Input Text ou set value selon UI
    # Simuler remplissage champs si exposés :
    # Fill Field By Index    7    ${latitude}
    # Fill Field By Index    8    ${longitude}
    # Fill Field By Index    9    ${radius}
    Sleep    1s


Capture Screenshot On Failure
    Run Keyword And Ignore Error    Capture Page Screenshot
    Run Keyword And Ignore Error    Log Source
    Run Keyword And Ignore Error    Log Page Source
    Close All Applications

Select Combobox Option By Index
    [Arguments]    ${combobox_index}    ${option_index}
    [Documentation]    Sélectionne une option dans une combobox par index
    Wait Until Page Contains Element    xpath=(//android.widget.Button)[${combobox_index}]
    Click Element    xpath=(//android.widget.Button)[${combobox_index}]
    Wait Until Page Contains Element    xpath=(//android.widget.Button)[${option_index}]
    Click Element    xpath=(//android.widget.Button)[${option_index}]

