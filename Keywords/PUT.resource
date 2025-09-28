*** Settings ***
Resource          ../Settings.robot

*** Keywords ***

PUT On [${THE_ENDPOINT}] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [${EXPECTED_STATUS_CODE}]
    [Documentation]    Send put request and validate status code
    ${Response}    PUT On Session    fakerestapi        url=${THE_ENDPOINT}    json=${PAYLOAD}     expected_status=${EXPECTED_STATUS_CODE}
    ${JSON_Response}    Run Keyword And Ignore Error        Convert String To Json    ${Response.content}
    Set Global Variable    ${JSON_Response}
    ${Actual_Response_Body}        Convert To String    ${JSON_Response}
    Set Global Variable    ${Actual_Response_Body}
