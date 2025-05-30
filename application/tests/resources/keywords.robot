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