*** Settings ***
Resource          ../Settings.robot
Resource          ../Keywords/GET.resource
Resource          ../Keywords/POST.resource
Resource          ../Keywords/PUT.resource
Resource          ../Keywords/DELETE.resource
Resource          ../Keywords/Validations.resource

Suite Setup       Create Session To API

Suite Teardown    # optionally close session, cleanup

*** Variables ***
${API}            api
${VERSION}        v1

*** Test Cases ***

TC01 Get All Activities
    [Documentation]    Get All Activities
    [Tags]    C101
    GET On [/${API}/${VERSION}/Activities] Endpoint And Validate That Status Code Is [200]
    ${activitylist}=    Get From List        ${JSON_Response}    1
    ${first_activity}=  Get From List    ${activitylist}    0
    # Extract fields
    ${id}=              Get From Dictionary    ${first_activity}    id
    ${title}=           Get From Dictionary    ${first_activity}    title
    ${dueDate}=         Get From Dictionary    ${first_activity}    dueDate
    ${completed}=       Get From Dictionary    ${first_activity}    completed
    # Validate values
    Should Be Equal As Integers    ${id}    1
    Should Be Equal                 ${title}    Activity 1
    Should Be Equal                 ${completed}    ${False}
    Should Match Regexp             ${dueDate}    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?([+-]\\d{2}:\\d{2}|Z)$

TC02 Get Activity By Valid Id
    GET On [/${API}/${VERSION}/Activities/1] Endpoint And Validate That Status Code Is [200]
    Validate That The Response Contains ['id': 1] Data
    Validate That The Response Contains ['title': 'Activity 1'] Data
    Validate That The Response Contains ['completed': ${False}] Data

TC03 Create Activity With Valid Payload
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_title}=      Generate Random String    5    [LETTERS]
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    title=${rnd_title}    dueDate=2025-01-01T00:00:00    completed=${False}
    POST On [/${API}/${VERSION}/Activities] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['id': ${rnd_id}] Data
    Validate That The Response Contains ['title': '${rnd_title}'] Data
    Validate That The Response Contains ['completed': ${False}] Data

TC04 Update Activity With Valid Payload
    ${PAYLOAD}=        Create Dictionary    id=1    title=Updated Activity    dueDate=2025-01-01T00:00:00    completed=${True}
    PUT On [/${API}/${VERSION}/Activities/1] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['title': 'Updated Activity'] Data
    Validate That The Response Contains ['completed': ${True}] Data

TC05 Delete Activity With Valid Id
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_title}=      Generate Random String    5    [LETTERS]
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    title=${rnd_title}    dueDate=2025-01-01T00:00:00    completed=${False}
    POST On [/${API}/${VERSION}/Activities] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    DELETE On [/${API}/${VERSION}/Activities/${rnd_id}] Endpoint And Validate Status Code Is [200]
    GET On [/${API}/${VERSION}/Activities/${rnd_id}] Endpoint And Validate That Status Code Is [404]

# =========================
# ❌ Negative Scenarios
# =========================

TC06 Get Activity By Invalid Id
    GET On [/${API}/${VERSION}/Activities/99999] Endpoint And Validate That Status Code Is [404]

TC07 Get Activity With Non-Numeric Id
    GET On [/${API}/${VERSION}/Activities/abc] Endpoint And Validate That Status Code Is [400]

TC08 Create Activity With Missing Required Field
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=        Create Dictionary    id=${EMPTY}    completed=${False}
    POST On [/${API}/${VERSION}/Activities] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC09 Create Activity With Invalid Data Type
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    title=Invalid Activity    dueDate=InvalidDate    completed=maybe
    POST On [/${API}/${VERSION}/Activities] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC10 Update Activity With Non-Existing Id
    ${PAYLOAD}=        Create Dictionary    id=99999    title=Ghost Activity    dueDate=2025-01-01T00:00:00    completed=${False}
    PUT On [/${API}/${VERSION}/Activities/a1] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC11 Delete Activity With Non-Existing Id
    DELETE On [/${API}/${VERSION}/Activities/ABC] Endpoint and Validate Status Code Is [400]
