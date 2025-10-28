*** Settings ***
Library           AppiumLibrary
Suite Setup       Reset State And Return Home
Suite Teardown    Close Application
Test Teardown     Capture Page Screenshot

*** Variables ***
${REMOTE_URL}         http://example-application-mobile:4723
${PLATFORM_NAME}      Android
${DEVICE_NAME}        emulator-5554
${APP_PACKAGE}        dev.vegito.app.android
${APP_ACTIVITY}       .MainActivity
${TIMEOUT}            10s

*** Test Cases ***
Click Plus Button Should Increment Counter
    Wait Until Page Contains Element    accessibility_id=You have pushed the button this many times:
    Element Should Be Visible           xpath=//android.view.View[@content-desc="0"]
    Click Element                       xpath=//android.widget.Button
    Wait Until Element Is Visible       xpath=//android.view.View[@content-desc="1"]    timeout=5s
    Click Element                       xpath=//android.widget.Button
    Wait Until Element Is Visible       xpath=//android.view.View[@content-desc="2"]    timeout=5s
    Click Element                       xpath=//android.widget.Button
    Wait Until Element Is Visible       xpath=//android.view.View[@content-desc="3"]    timeout=5s
    Click Element                       xpath=//android.widget.Button
    Wait Until Element Is Visible       xpath=//android.view.View[@content-desc="4"]    timeout=5s
    Element Should Be Visible           xpath=//android.view.View[@content-desc="4"]
*** Keywords ***
Reset State And Return Home
    [Documentation]    Réinitialise l'état de l'application et revient à la page d'accueil.
    # Reset Firestore And Storage Before Test
    Open Application    ${REMOTE_URL}    
    ...    platformName=${PLATFORM_NAME}    
    ...    automationName=UiAutomator2    
    ...    appPackage=${APP_PACKAGE}    
    ...    appActivity=${APP_ACTIVITY}    
    ...    noReset=false
    ...    fullReset=false
    ...    dontStopAppOnReset=true
    # Clear Pictures Folder
    # Handle Permission Popup
    # Go To Home Page