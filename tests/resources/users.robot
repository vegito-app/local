*** Settings ***
Library    RequestsLibrary
# Library    OperatingSystem
Library    Firebase.py
Library    AppiumLibrary
Resource    keywords.robot

*** Keywords ***
Delete All Users
    [Documentation]    Supprime tous les utilisateurs de Firebase Auth.
    Create Session    firebase    ${FIREBASE_AUTH_EMULATOR_HOST}
    ${result}=    Firebase.purge_test_users
    Log    ${result}x