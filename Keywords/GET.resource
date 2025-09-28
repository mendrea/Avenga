*** Settings ***
Resource          ../Settings.robot

*** Keywords ***

GET on [${ENDPOINT}] endpoint and validate that status code is [${EXPECTED_STATUS_CODE}]
    [Documentation]    Send get request and validate status code
    ${Response}    GET On Session    fakerestapi        url=${ENDPOINT}     expected_status=${EXPECTED_STATUS_CODE}
    ${JSON_Response}    Run Keyword And Ignore Error        Convert String To Json    ${Response.content}
    Set Global Variable    ${JSON_Response}
    ${Actual_Response_Body}        Convert To String    ${JSON_Response}
    Set Global Variable    ${Actual_Response_Body}
