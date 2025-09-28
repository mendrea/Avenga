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

TC01 Get All Users
    [Documentation]    Get All Users
    [Tags]    C401
    GET On [/${API}/${VERSION}/Users] Endpoint And Validate That Status Code Is [200]
    ${userlist}=      Get From List    ${JSON_Response}    1
    ${first_user}=    Get From List    ${userlist}    0
    # Extract fields
    ${id}=            Get From Dictionary    ${first_user}    id
    ${userName}=      Get From Dictionary    ${first_user}    userName
    ${password}=      Get From Dictionary    ${first_user}    password
    # Validate values
    Should Be Equal As Integers    ${id}        1
    Should Not Be Empty            ${userName}
    Should Not Be Empty            ${password}

TC02 Get User By Valid Id
    GET On [/${API}/${VERSION}/Users/1] Endpoint And Validate That Status Code Is [200]
    Validate That The Response Contains ['id': 1] Data
    Validate That The Response Contains ['userName': 'User 1'] Data
    Validate That The Response Contains ['password': 'Password1'] Data

TC03 Create User With Valid Payload
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_user}=       Generate Random String    5    [LETTERS]
    ${rnd_pass}=       Generate Random String    8    [LETTERS]
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    userName=${rnd_user}    password=${rnd_pass}
    POST On [/${API}/${VERSION}/Users] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['id': ${rnd_id}] Data
    Validate That The Response Contains ['userName': '${rnd_user}'] Data

TC04 Update User With Valid Payload
    ${PAYLOAD}=        Create Dictionary    id=1    userName=UpdatedUser    password=UpdatedPass
    PUT On [/${API}/${VERSION}/Users/1] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['userName': 'UpdatedUser'] Data

TC05 Delete User With Valid Id
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_user}=       Generate Random String    5    [LETTERS]
    ${rnd_pass}=       Generate Random String    8    [LETTERS]
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    userName=${rnd_user}    password=${rnd_pass}
    POST On [/${API}/${VERSION}/Users] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    DELETE On [/${API}/${VERSION}/Users/${rnd_id}] Endpoint And Validate Status Code Is [200]
    GET On [/${API}/${VERSION}/Users/${rnd_id}] Endpoint And Validate That Status Code Is [404]

# =========================
# ❌ Negative Scenarios
# =========================

TC06 Get User By Invalid Id
    GET On [/${API}/${VERSION}/Users/99999] Endpoint And Validate That Status Code Is [404]

TC07 Get User With Non-Numeric Id
    GET On [/${API}/${VERSION}/Users/abc] Endpoint And Validate That Status Code Is [400]

TC08 Create User With Missing Required Field
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=        Create Dictionary    id=${EMPTY}    userName=${EMPTY}
    POST On [/${API}/${VERSION}/Users] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC09 Create User With Invalid Data Type
    ${PAYLOAD}=        Create Dictionary    id=${EMPTY}    userName=123    password=456
    POST On [/${API}/${VERSION}/Users] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC10 Update User With Non-Existing Id
    ${PAYLOAD}=        Create Dictionary    id=id1111    userName=GhostUser    password=GhostPass
    PUT On [/${API}/${VERSION}/Users/id1111] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC11 Delete User With Non-Existing Id
    DELETE On [/${API}/${VERSION}/Users/ABC] Endpoint And Validate Status Code Is [400]
