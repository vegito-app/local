*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem

*** Variables ***
${FIREBASE_EMULATORS_HOST}    %{FIREBASE_EMULATORS_HOST=firebase-emulators}
${APPLICATION_BACKEND_URL}    %{APPLICATION_BACKEND_URL=application-backend:8080}

${FIREBASE_HOST}              http://${FIREBASE_EMULATORS_HOST}:9099
${BACKEND_HOST}               http://${APPLICATION_BACKEND_URL}

*** Test Cases ***
Connexion Firebase anonyme et appel API backend
    [Documentation]    Se connecte en anonyme avec Firebase et appelle le backend avec le token
    Create Session    firebase    ${FIREBASE_HOST}
    ${payload}=    Create Dictionary    returnSecureToken=True
    ${response}=    POST On Session    firebase    url=/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200
    ${idToken}=    Set Variable    ${response.json()["idToken"]}

    Create Session    backend    ${BACKEND_HOST}
    ${headers}=    Create Dictionary    Authorization=Bearer ${idToken}
    ${res}=    GET    backend    /api/profile    headers=${headers}
    Status Should Be    200