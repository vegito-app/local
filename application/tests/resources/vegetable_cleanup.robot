*** Settings ***
Library    Firebase.py

*** Keywords ***
Purge Test Vegetables
    ${result}=    Firebase.purge_test_vegetables
    Log    ${result}