*** Settings ***
Library           RequestsLibrary
Library           Collections

Resource         ../resources/keywords.robot
Resource         ../resources/users.robot

*** Variables ***
${FIREBASE_AUTH_EMULATOR_HOST}    http://localhost:9099
${APPLICATION_BACKEND_URL}         http://localhost:8080
${API_KEY}                        fake-api-key

*** Keywords ***
Reset Firestore and Users Before Test
    [Documentation]    Nettoie Firestore et supprime les comptes utilisateurs avant les tests.
    ${result1}=    Reset Firestore
    Log    ${result1}
    ${result2}=    Delete All Users
    Log    ${result2}

Sign In Anonymously
    [Documentation]    S'inscrire anonymement auprès de l'émulateur Firebase Auth.
    Create Session    firebase    ${FIREBASE_AUTH_EMULATOR_HOST}
    ${payload}=    Create Dictionary    returnSecureToken=True
    ${response}=    POST On Session    firebase    url=/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200
    ${idToken}=    Set Variable    ${response.json()['idToken']}
    [Return]    ${idToken}

Validate Account Access Denied
    [Arguments]    ${idToken}
    Create Session    backend    ${APPLICATION_BACKEND_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${idToken}
    ${response}=    GET On Session    backend    /api/account/validate-check    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    403

Simulate Account Validation
    [Arguments]    ${idToken}
    Create Session    backend    ${APPLICATION_BACKEND_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${idToken}
    ${response}=    POST On Session    backend    /api/account/validate    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

Validate Account Access Granted
    [Arguments]    ${idToken}
    Create Session    backend    ${APPLICATION_BACKEND_URL}
    ${headers}=    Create Dictionary    Authorization=Bearer ${idToken}
    ${response}=    GET On Session    backend    /api/account/validate-check    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200

Link Account With Email
    [Arguments]    ${idToken}    ${email}    ${password}
    Create Session    firebase    ${FIREBASE_AUTH_EMULATOR_HOST}
    ${payload}=    Create Dictionary
    ...    idToken=${idToken}
    ...    email=${email}
    ...    password=${password}
    ...    returnSecureToken=True
    ${response}=    POST On Session    firebase    url=/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200

Link Account With Google
    [Arguments]    ${idToken}
    Create Session    firebase    ${FIREBASE_AUTH_EMULATOR_HOST}
    ${payload}=    Create Dictionary
    ...    postBody=id_token=fake-google-id-token&providerId=google.com&requestUri=http://localhost
    ...    requestUri=http://localhost
    ...    returnIdpCredential=True
    ...    returnSecureToken=True
    ...    idToken=${idToken}
    ${response}=    POST On Session    firebase    /identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=${API_KEY}    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200

Link Account With Facebook
    [Arguments]    ${idToken}
    Create Session    firebase    ${FIREBASE_AUTH_EMULATOR_HOST}
    ${payload}=    Create Dictionary
    ...    postBody=access_token=fake-facebook-access-token&providerId=facebook.com&requestUri=http://localhost
    ...    requestUri=http://localhost
    ...    returnIdpCredential=True
    ...    returnSecureToken=True
    ...    idToken=${idToken}
    ${response}=    POST On Session    firebase    /identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=${API_KEY}    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200

*** Test Cases ***
Test Validation Workflow
    [Documentation]    Test complet du workflow de validation d'un compte anonyme vers un compte email lié.
    ${idToken}=    Sign In Anonymously
    Validate Account Access Denied    ${idToken}
    Simulate Account Validation    ${idToken}
    Validate Account Access Granted    ${idToken}
    Link Account With Email    ${idToken}    testuser@example.com    TestPassword123

Test Validation Workflow With Google
    [Documentation]    Test complet du workflow de validation d'un compte anonyme avec liaison Google.
    ${idToken}=    Sign In Anonymously
    Validate Account Access Denied    ${idToken}
    Simulate Account Validation    ${idToken}
    Validate Account Access Granted    ${idToken}
    Link Account With Google    ${idToken}

Reset Firestore and Users Before Test
    [Documentation]    Nettoie Firestore et supprime les comptes utilisateurs avant les tests.
    ${result1}=    Reset Firestore
    Log    ${result1}
    ${result2}=    Delete All Users
    Log    ${result2}

Create and Delete Test User
    [Documentation]    Crée un utilisateur de test et le supprime.
    ${result1}=    Create Test User    testfire@example.com    Password123
    Log    ${result1}
    ${result2}=    Delete Test User    testfire@example.com
    Log    ${result2}
Test Validation Workflow With Facebook
    [Documentation]    Test complet du workflow de validation d'un compte anonyme avec liaison Facebook.
    ${idToken}=    Sign In Anonymously
    Validate Account Access Denied    ${idToken}
    Simulate Account Validation    ${idToken}
    Validate Account Access Granted    ${idToken}
    Link Account With Facebook    ${idToken}

*** Settings ***
Test Setup        Reset Firestore and Users Before Test