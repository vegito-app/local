*** Settings ***
Library           AppiumLibrary

*** Variables ***
${REMOTE_URL}     http://android-studio:4723/wd/hub
${PLATFORM_NAME}  Android
${APP_PACKAGE}    com.example.app
${APP_ACTIVITY}   .MainActivity

*** Test Cases ***
Ajouter une carotte depuis l’interface
    Open Application    ${REMOTE_URL}    platformName=${PLATFORM_NAME}    appPackage=${APP_PACKAGE}    appActivity=${APP_ACTIVITY}
    Wait Until Page Contains Element    xpath=//android.widget.Button[@text="Ajouter un légume"]
    Click Element    xpath=//android.widget.Button[@text="Ajouter un légume"]
    Input Text       xpath=//android.widget.EditText    Carotte
    Click Element    xpath=//android.widget.Button[@text="Valider"]
    Page Should Contain Element    xpath=//android.view.View[@text="Carotte"]
