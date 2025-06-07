*** Settings ***
Library    AppiumLibrary
Library    Process
Resource         ../resources/vegetable.robot

*** Keywords ***
Fill Field By Index
    [Arguments]    ${index}    ${value}
    Wait Until Keyword Succeeds    10x    1s    Page Should Contain Element    xpath=(//android.widget.EditText)[${index}]
    Click Element                  xpath=(//android.widget.EditText)[${index}]
    Input Text                     xpath=(//android.widget.EditText)[${index}]    ${value}
    Press Keycode                  66

Swipe Until Element Is Visible
    [Arguments]    ${locator}
    ${MAX_SWIPES}=    Set Variable    5
    FOR    ${index}    IN RANGE    ${MAX_SWIPES}
        ${visible}=    Run Keyword And Return Status    Page Should Contain Element    ${locator}
        Exit For Loop If    ${visible}
        Swipe    500    1600    500    400    800
    END
    Wait Until Page Contains Element    ${locator}
    Click Element    ${locator}

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
    Firebase.reset_firestore
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