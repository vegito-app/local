*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem

*** Variables ***
${FIREBASE_AUTH_EMULATOR_HOST}    %{FIREBASE_AUTH_EMULATOR_HOST}
${APPLICATION_BACKEND_URL}    %{APPLICATION_BACKEND_URL_DEBUG}

${FIREBASE_AUTH_URL}              http://%{FIREBASE_AUTH_EMULATOR_HOST}
${BACKEND_URL}               ${APPLICATION_BACKEND_URL}

*** Test Cases ***
Connexion Firebase anonyme et appel API backend
    [Documentation]    Se connecte en anonyme avec Firebase et appelle le backend avec le token
    Create Session    firebase    ${FIREBASE_AUTH_URL}
    ${payload}=    Create Dictionary    returnSecureToken=True
    ${response}=    POST On Session    firebase    url=/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200
    ${idToken}=    Set Variable    ${response.json()["idToken"]}

    Create Session    backend    ${APPLICATION_BACKEND_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${idToken}
    ${res}=    GET On Session  backend    /api/auth-check    headers=${headers}
    Status Should Be    200