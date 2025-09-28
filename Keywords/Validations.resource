*** Settings ***
Resource          ../Settings.robot

*** Keywords ***

Validate that the response contains [${EXPECTED_DATA}] data
    [Documentation]    Validation of response
    Should Contain    ${Actual_Response_Body}        ${EXPECTED_DATA}        ignore_case=${False}

