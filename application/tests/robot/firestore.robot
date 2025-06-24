*** Settings ***
Resource         ../resources/vegetable.robot
Library          AppiumLibrary
Suite Setup      Firebase.purge_test_vegetables
Resource         ../resources/keywords.robot
Library           AppiumLibrary
Library           Collections

*** Variables ***
${REMOTE_URL}     http://android-studio:4723
${PLATFORM_NAME}  Android
${APP_PACKAGE}    dev.vegito.app.android
${APP_ACTIVITY}   .MainActivity

*** Test Cases ***
Test Firestore Snapshot and Restore
    [Documentation]    Prend un snapshot Firestore, insère des données, restaure, puis vérifie que les données ont bien disparu.
    
    ${snapshot}=    Snapshot Firestore
    Log    Snapshot pris

    ${insert_result}=    Insert Test Data    vegetables    artichoke    {"color": "green", "season": "spring"}
    Log    ${insert_result}

    ${after_insert}=    Get Vegetable Document    artichoke
    Log    After insert: ${after_insert}
    Should Be Equal As Strings    ${after_insert["color"]}    green

    ${restore_result}=    Restore Firestore Snapshot    ${snapshot}
    Log    ${restore_result}

    ${after_restore}=    Get Vegetable Document    artichoke
    Log    After restore: ${after_restore}
    ${expected}=    Evaluate    {'color': 'green', 'season': 'spring'}
    Dictionaries Should Be Equal        ${after_restore}    ${expected}